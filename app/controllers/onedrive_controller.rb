class OnedriveController < ApplicationController
	# Onedrive API: https://dev.onedrive.com/README.htm

	require 'oauth2'
	require 'rest-client'
	require 'json'

	before_action :get_token, only: [:create_folder, :callback, :delete_item, :dirty_check, :download, :upload]


	def authorize
		client = OAuth2::Client.new(Rails.application.secrets.onedrive_key,
	                                Rails.application.secrets.onedrive_secret,
	                                :site => 'https://login.live.com',
	                                :authorize_url => '/oauth20_authorize.srf')
		redirect_to client.auth_code.authorize_url(:redirect_uri => onedrive_callback_url, :scope => "onedrive.readwrite wl.offline_access")
	end

	def deauthorize
		current_user.services.find_by(name: "Onedrive").destroy
        Folder.roots.find_by(name: "Onedrive_Root").destroy
        flash[:success] = "You have successfully deauthorized Onedrive."
        redirect_to root_path
	end

	def callback
		flash[:success] = "You have successfully authorized Onedrive."
		verb = "get"
		response = rest_call("https://api.onedrive.com/v1.0/drive/root:/")
		Folder.roots.create(name: "Onedrive_Root", folder_path: "/drive/root:/", user_id: current_user.id, dirty_flag: response["lastModifiedDateTime"]) unless Folder.roots.find_by(name: "Onedrive_Root")
		get_folders
		redirect_to root_path
	end

	def dirty_check
		folder = Folder.find(params[:id])
		path = make_url_safe(folder.folder_path)
		response = rest_call("https://api.onedrive.com/v1.0#{path}")
		if Time.parse(folder.dirty_flag) < Time.parse(response["lastModifiedDateTime"])
			#Update the dirty flag
			folder.dirty_flag = response["lastModifiedDateTime"]
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
		# Get rid of spaces in file name to make it url safe
		path = make_url_safe(file.folder_path)
		location = RestClient.get("https://api.onedrive.com/v1.0#{path}:/content", {:Authorization => "Bearer #{@token}", :content_type => "application/json"})
		send_data(location, :filename => file.name)
	end

	def upload
		file = File.new(File.join(Rails.root.join('tmp', params[:uploaded_file].original_filename)), "wb+")
		file.write(params[:uploaded_file].read)
        file.close
        Upload.perform_async("onedrive", @token, params[:path]  + params[:uploaded_file].original_filename, file.path)
		# path = params[:path] + params[:uploaded_file].original_filename
		# rest_call("https://api.onedrive.com/v1.0#{path}:/content", "put", params[:uploaded_file].read, "application/octet-stream")
        redirect_to root_path
    end

	def create_folder
		parent = Folder.find(params[:parent_id])
		path = make_url_safe(parent.folder_path)
		name = make_url_safe(params[:name])
		rest_call("https://api.onedrive.com/v1.0#{path}:/children", "post", { 'name' => name, 'folder' => {} }.to_json)
		redirect_to root_path
	end

	def delete_item
		unless item = Folder.find(params[:id])
            parent = Folder.find(params[:parent_id])
            item = parent.user_files.find(params[:id])
        end
		path = make_url_safe(item.folder_path)
		rest_call("https://api.onedrive.com/v1.0#{path}", "delete")
		#RestClient.delete("https://api.onedrive.com/v1.0#{path}", {:Authorization => "Bearer #{@token}"})
		redirect_to root_path, status: 303
	end

  private

	def get_folders(parent = Folder.roots.find_by(name: "Onedrive_Root"))
		# This is done for the url encoding to change any space in the path to be '+' so it's url friendly
		path = make_url_safe(parent.folder_path)
		response = rest_call("https://api.onedrive.com/v1.0#{path}:/children")
		#Iterates through the contents (where the children of the folder are stored)
		response["value"].each do |folder|
		  full_path =  folder["parentReference"]["path"] + "/" + folder["name"]
		  name = folder["name"]
		  if(!folder["folder"].nil?)
			  #if it's a folder add as a child folder
			  parent.children.create(name: name, folder_path: full_path, user_id: current_user.id, dirty_flag: folder["lastModifiedDateTime"]) unless parent.children.find_by(folder_path: full_path)

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

	# Makes a token instance variable by either responding with existing onedrive
	# or creating a new one if it doesn't exists or it's expired
	def get_token
		service = current_user.services.find_by(name: "Onedrive")
		client = OAuth2::Client.new(Rails.application.secrets.onedrive_key,
									Rails.application.secrets.onedrive_secret,
									:site => 'https://login.live.com',
									:response_type => 'code',
									:token_url => '/oauth20_token.srf')
		# If service doesn't exist, create a new token and create the service
		if !service
			token = client.auth_code.get_token(params[:code], :redirect_uri => onedrive_callback_url)
			drive_info = JSON.parse(RestClient.get("https://api.onedrive.com/v1.0/drives/me", {:Authorization => "Bearer #{token.token}"}))
			service = current_user.services.create!(name: "Onedrive", access_token: token.to_hash, used_space: drive_info["quota"]["used"], total_space: drive_info["quota"]["total"])
		# Else if there is a service and the token is expired refresh it and save it
		elsif Time.at(eval(service.access_token)[:expires_at]) < Time.now
			token = OAuth2::AccessToken.from_hash(client, eval(service.access_token))
			service.update(access_token: token.refresh!.to_hash)
		end
		# Return the access token
		@token = eval(service.access_token)[:access_token]
	end

	def update_space
        response = JSON.parse(RestClient.get("https://api.onedrive.com/v1.0/drives/me", {:Authorization => "Bearer #{@token}"}))
        current_user.services.find_by(name: "Onedrive").update( used_space: response["quota"]["used"], total_space: response["quota"]["total"])
    end

	def rest_call(url, verb="get", payload=nil, contentType="json")
		verb === "delete" ? RestClient::Request.execute(method: verb, url: url, payload: payload, headers: {Authorization: "Bearer #{@token}", content_type: contentType}) :
				JSON.parse(RestClient::Request.execute(method: verb, url: url, payload: payload, headers: {Authorization: "Bearer #{@token}", content_type: contentType}))
	end

	def make_url_safe(url)
		url.tr(' ', '+')
	end
end
