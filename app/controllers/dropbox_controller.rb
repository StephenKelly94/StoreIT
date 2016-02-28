class DropboxController < ApplicationController
    require 'dropbox_sdk'
    require 'json'


    before_action :create_client, only: [:list, :download, :dirty_check, :create_folder, :delete_folder]

    def authorize
        authorize_url = get_web_auth.start()
        redirect_to authorize_url
    end

    def deauthorize
        current_user.services.find_by(name: "Dropbox").delete
        flash[:success] = "You have successfully deauthorized dropbox."
        redirect_to root_path
    end

    def dropbox_callback
        access_token, user_id, url_state = get_web_auth.finish(params)
        if(!current_user.services.find_by(name: "Dropbox"))
            current_user.services.create!(name: "Dropbox", access_token: access_token)
            ##Create root folder for dropbox
            Folder.roots.create(name: "Dropbox_Root", folder_path: "/", user_id: current_user.id) unless Folder.roots.find_by(name: "Dropbox_Root")
            flash[:success] = "You have successfully authorized dropbox."
        else
            flash[:error] = "Already authenticated"
        end
        #This is done because of the before action on list
        redirect_to root_path
    end

    def dirty_check
        @folder = Folder.find(params[:id])
        @api_hash = @client.metadata(@folder.folder_path)["hash"]
        if @folder.dirty_flag != @api_hash
            #Update the dirty flag
            @folder.dirty_flag = @api_hash
            #Destroy older files and folders
            @folder.children.destroy
            @folder.user_files.destroy
            @folder.save
            get_folders(@folder)
        end
        redirect_to root_path
    end

    def list
        get_folders
        redirect_to root_path
    end

    def download
        @parent=Folder.find(params[:parent_id])
        @file = @parent.user_files.find(params[:id])
        send_data(@client.get_file(@file.folder_path), :filename => @file.name)
    end

    def create_folder
        parent = Folder.find(params[:parent_id])
        parent.is_root? ? path=parent.folder_path : path=parent.folder_path+"/"
        puts @client.file_create_folder(path + params[:id].to_s)
        redirect_to root_path
    end

    def delete_folder
        unless item = Folder.find(params[:id])
            parent = Folder.find(params[:parent_id])
            item = parent.user_files.find(params[:id])
        end
        response = @client.file_delete(item.folder_path)
        redirect_to root_path, status: 303
    end

  private

    #Puts all the files/folders of dropbox into database
    #In the future should use depth to make api call efficient
    def get_folders(parent = Folder.roots.find_by(name: "Dropbox_Root"))
        folders = @client.metadata(parent.folder_path)
        #Iterates through the contents (where the children of the folder are stored)
        folders["contents"].each do |folder|
            full_path =  folder["path"]
            name = full_path.sub(parent.folder_path, "").tr('/', '')
            if(folder["is_dir"])
                #if it's a folder add as a child folder
                parent.children.create(name: name, folder_path: full_path, user_id: current_user.id, dirty_flag: folders["hash"]) unless parent.children.find_by(folder_path: full_path)

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
        current_user.services.find_by(name: "Dropbox") ? @client = DropboxClient.new(current_user.services.find_by(name: "Dropbox").access_token)
            : @client=current_user.services.find_by(name: "Dropbox")
    end

end
