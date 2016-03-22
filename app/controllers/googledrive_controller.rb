class GoogledriveController < ApplicationController
    # https://developers.google.com/drive/v2/reference/
    # https://github.com/google/signet/blob/master/lib/signet/oauth_2/client.rb
    # https://security.google.com/settings/u/0/security/permissions?pli=1

    before_action :get_token, only: [:create_folder, :callback, :delete_item, :deauthorize, :dirty_check, :download, :upload]

    def authorize
        client = OAuth2::Client.new(Rails.application.secrets.googledrive_key,
									Rails.application.secrets.googledrive_secret,
									:site => 'https://accounts.google.com',
									:authorize_url => '/o/oauth2/auth')
        redirect_to client.auth_code.authorize_url(:redirect_uri => googledrive_callback_url, :scope => 'https://www.googleapis.com/auth/drive', :access_type => 'offline')
    end

    def callback
        root = rest_call("https://www.googleapis.com/drive/v2/about")
        response = rest_call("https://www.googleapis.com/drive/v2/files/#{root['rootFolderId']}")
        Folder.roots.create(name: "Googledrive_Root", service_folder_id: root["rootFolderId"], dirty_flag: response["modifiedByMeDate"], folder_path: "/", user_id: current_user.id) unless Folder.roots.find_by(name: "Googledrive_Root")
        get_folders
        redirect_to root_url
    end

    def deauthorize
        RestClient.get("https://accounts.google.com/o/oauth2/revoke?token=#{@token}")
		current_user.services.find_by(name: "Googledrive").destroy
        Folder.roots.find_by(name: "Googledrive_Root").destroy
        flash[:success] = "You have successfully deauthorized Google Drive."
        redirect_to root_path
	end

    def download
        parent=Folder.find(params[:parent_id])
		file = parent.user_files.find(params[:id])
		# Get rid of spaces in file name to make it url safe
		file_id = file.service_file_id
        # Can't use rest_call helper because of parsing downloaded data
		location = RestClient.get("https://www.googleapis.com/drive/v2/files/#{file_id}?alt=media", {:Authorization => "Bearer #{@token}", :content_type => "application/json" })
		send_data(location, :filename => file.name)
    end

    def dirty_check
        # TODO: Refine this

        folder = Folder.roots.find_by(name: "Googledrive_Root")
        #Destroy older files and folders
        folder.children.destroy
        folder.user_files.destroy
        folder.save
        get_folders
		redirect_to root_path
    end

    def upload
		file = File.new(File.join(Rails.root.join('tmp', params[:uploaded_file].original_filename)), "wb+")
		file.write(params[:uploaded_file].read)
        file.close
        parent = Folder.find_by(folder_path: params[:path])
        payload = {
                      "title" => params[:uploaded_file].original_filename,
                      "parents" => [{"id" => parent.service_folder_id}],
                    }
        Upload.perform_async("googledrive", @token, payload.to_json, file.path)
        redirect_to root_path
    end

    def create_folder
        parent = Folder.find(params[:parent_id])
        parent_service_id = parent.service_folder_id
        payload = {
                      'title' => params[:name],
                      'parents'=> [{'id' => parent_service_id}],
                      'mimeType' => 'application/vnd.google-apps.folder'
                    }
		rest_call("https://www.googleapis.com/drive/v2/files", "post", payload.to_json)
		redirect_to root_path
    end

    def delete_item
        if item = Folder.find(params[:id])
            service_id = item.service_folder_id
		else
            parent = Folder.find(params[:parent_id])
            item = parent.user_files.find(params[:id])
            service_id = item.service_file_id
        end
		rest_call("https://www.googleapis.com/drive/v2/files/#{service_id}", "delete")
		redirect_to root_path, status: 303
	end

  private

    def get_token
        # TODO: Make refresh token work better
        service = current_user.services.find_by(name: "Googledrive")
        client = OAuth2::Client.new(Rails.application.secrets.googledrive_key,
        							Rails.application.secrets.googledrive_secret,
        							:site => 'https://accounts.google.com',
        							:response_type => 'code',
        							:token_url => '/o/oauth2/token',
                                    :access_type => 'offline')
        # If service doesn't exist, create a new token and create the service
        if !service
        	token = client.auth_code.get_token(params[:code], :redirect_uri => googledrive_callback_url)
        	drive_info = JSON.parse(RestClient.get("https://www.googleapis.com/drive/v2/about", {:Authorization => "Bearer #{token.token}"}))
         	service = current_user.services.create!(name: "Googledrive", access_token: token.to_hash, used_space: drive_info["quotaBytesUsedAggregate"], total_space: drive_info["quotaBytesTotal"])
        # Else if there is a service and the token is expired refresh it and save it
        elsif Time.at(eval(service.access_token)[:expires_at]) < Time.now
        	token = OAuth2::AccessToken.from_hash(client, eval(service.access_token))
        	service.update(access_token: token.refresh!.to_hash)
        end
        # Return the access token
        puts "=========================="
        puts service.inspect
        @token = eval(service.access_token)[:access_token]
    end

    def get_folders(parent = Folder.roots.find_by(name: "Googledrive_Root"))
        service_id = Folder.id_to_service_id(parent.id)
        response = rest_call("https://www.googleapis.com/drive/v2/files/#{service_id}/children")
        #Iterates through the contents (where the children of the folder are stored)
        response["items"].each do |folder|
            file_info = rest_call("https://www.googleapis.com/drive/v2/files/#{folder['id']}")
            name = file_info["title"]
            parent.is_root? ? full_path =  parent.folder_path + name : full_path =  parent.folder_path + "/" + name
            # If it's mimeType is a folder
            if(file_info["mimeType"] === "application/vnd.google-apps.folder")
                  #if it's a folder add as a child folder
                  # Dirty flag stored in how much space is taken up in service beacue google api has stale modified date
                  parent.children.create(name: name, service_folder_id: folder["id"], folder_path: full_path, user_id: current_user.id) unless parent.children.find_by(folder_path: full_path)
                  #recursively call to get the children of this folder
                  get_folders(parent.children.find_by(folder_path: full_path))
            else
                  ##if it's a file add it as a user_file unless it exists already
                  parent.user_files.create(name: name, folder_path: full_path, service_file_id: folder["id"],
                	  parent: parent.id) unless parent.user_files.find_by(folder_path: full_path)
            end
        end

    end
end
