class DropboxController < ApplicationController
    require 'dropbox_sdk'
    require 'json'

    before_action :create_client, only: [:create_folder, :delete_item, :dirty_check, :hard_refresh, :download, :upload]

    def authorize
        authorize_url = get_web_auth.start()
        redirect_to authorize_url
    end

    def deauthorize
        current_user.services.find_by(name: "Dropbox").delete
        Folder.roots.find_by(name: "Dropbox_Root").destroy
        flash[:success] = "You have successfully deauthorized Dropbox."
        redirect_to root_path
    end

    def callback
        access_token, user_id, url_state = get_web_auth.finish(params)
        @client = DropboxClient.new(access_token)
        response = @client.account_info
        current_user.services.create!(name: "Dropbox", access_token: access_token, used_space: response["quota_info"]["normal"], total_space: response["quota_info"]["quota"])
        ##Create root folder for dropbox
        Folder.roots.create(name: "Dropbox_Root", folder_path: "/", dirty_flag: @client.metadata("/")["hash"], user_id: current_user.id) unless Folder.roots.where(name: "Dropbox_Root", user_id: current_user.id).first
        flash[:success] = "You have successfully authorized Dropbox."
        get_folders
        redirect_to root_path
    end

    def hard_refresh
        folder = Folder.roots.find_by(name: "Dropbox_Root")
        #Destroy older files and folders
        folder.children.destroy
        folder.user_files.destroy
        folder.save
        update_space
        get_folders
		redirect_to root_path
    end

    def dirty_check
        folder = Folder.find(params[:id])
        api_hash = @client.metadata(folder.folder_path)["hash"]
        if folder.dirty_flag != api_hash
            #Update the dirty flag
            folder.dirty_flag = api_hash
            #Destroy older files and folders
            folder.children.destroy
            folder.user_files.destroy
            folder.save
            update_space
            get_folders(folder)
        end
        redirect_to root_path
    end

    def download
        parent=Folder.find(params[:parent_id])
        file = parent.user_files.find(params[:id])
        send_data(@client.get_file(file.folder_path), :filename => file.name)
    end

    def upload
        file = File.new(File.join(Rails.root.join('tmp', params[:uploaded_file].original_filename)), "wb+")
		file.write(params[:uploaded_file].read)
        file.close
        Upload.perform_async("dropbox", current_user.services.find_by(name: "Dropbox").access_token, params[:path] + "/" + params[:uploaded_file].original_filename, file.path)
        respond_to do |format|
          format.json { render :json => { "name" => params[:uploaded_file].original_filename}.to_json }
        end
    end

    def create_folder
        parent = Folder.find(params[:parent_id])
        parent.is_root? ? path=parent.folder_path : path=parent.folder_path+"/"
        @client.file_create_folder(path + params[:name].to_s)
        respond_to do |format|
          format.json { render :json => params.as_json(:only => :name) }
        end
    end

    def delete_item
        unless item = Folder.find(params[:id])
            parent = Folder.find(params[:parent_id])
            item = parent.user_files.find(params[:id])
        end
        @client.file_delete(item.folder_path)
        respond_to do |format|
          format.json { render :json => item.as_json(:only => :name) }
        end
    end

  private

    #Puts all the files/folders of dropbox into database
    #In the future should use depth to make api call efficient
    def get_folders(parent = Folder.roots.where(name: "Dropbox_Root", user_id: current_user.id).first)
        folders = @client.metadata(parent.folder_path)
        if !parent.is_root? and parent.dirty_flag
            # Set the hash of the parent node, since dropbox only returns hash of current folder not children
            puts parent.update(dirty_flag: folders["hash"])
        end
        #Iterates through the contents (where the children of the folder are stored)
        folders["contents"].each do |folder|
            full_path =  folder["path"]
            name = full_path.sub(parent.folder_path, "").tr('/', '')
            if(folder["is_dir"])
                #if it's a folder add as a child folder
                parent.children.create(name: name, folder_path: full_path, user_id: current_user.id) unless parent.children.find_by(folder_path: full_path)

                #recursively call to get the children of this folder
                #get_folders(parent.children.find_by(folder_path: full_path), depth+1, child_folders)
                get_folders(parent.children.find_by(folder_path: full_path))
            else
                ##if it's a file add it as a user_file unless it exists already
                parent.user_files.create(name: name, folder_path: full_path,
                    parent: parent.id) unless parent.user_files.find_by(folder_path: full_path)
            end
        end
    end

    #Create the url for ouath authentication
    def get_web_auth
        return DropboxOAuth2Flow.new(Rails.application.secrets.dropbox_key, Rails.application.secrets.dropbox_secret, dropbox_callback_url, session, :dropbox_auth_csrf_token)
    end

    #Creates a new client
    def create_client
        @client = DropboxClient.new(current_user.services.find_by(name: "Dropbox").access_token) if current_user.services.find_by(name: "Dropbox")
    end

    def update_space
        response = @client.account_info
        current_user.services.find_by(name: "Dropbox").update( used_space: response["quota_info"]["normal"], total_space: response["quota_info"]["quota"])
    end

end
