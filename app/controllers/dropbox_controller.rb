class DropboxController < ApplicationController
    require 'dropbox_sdk'
    require 'json'

    ##For maximum depth in listing
    @@MAX_DEPTH = 3

    before_action :create_client, only: [:list, :download]

    def authorize
        authorize_url = get_web_auth.start()
        redirect_to authorize_url
    end

    def deauthorize
        current_user.services.find_by(name: "Dropbox").delete
        flash[:success] = "You have successfully deauthorized dropbox."
        redirect_to "/"
    end

    def dropbox_callback
        access_token, user_id, url_state = get_web_auth.finish(params)
        if(!current_user.services.find_by(name: "Dropbox"))
            current_user.services.create!(name: "Dropbox", access_token: access_token)
            ##Create root folder for dropbox
            current_user.folders.create!(name: "Dropbox_Root", path: "/", parent: "")
            flash[:success] = "You have successfully authorized dropbox."
        else
            flash[:error] = "Already authenticated"
        end
        redirect_to "/"

    end

    #List files/folders in a given parent folder (default is root folder)
    #Depth is also provided for effiency to load only three levels (default is 0)
    def list(parent = current_user.folders.find_by(path: "/"), depth = 0)
        if depth < @@MAX_DEPTH
            folders = @client.metadata(parent.path)
            #Iterates through the contents (where the children of the folder are stored)
            folders["contents"].each do |folder|
                puts "---------------------------------------------------------------"
                puts folder["path"],  "DEPTH " + depth.to_s + "\n"
                if(folder["is_dir"])
                    # If it's root path just set it as "/" else set it as the parent path plus itself'
                    parent.path == "/" ? full_path =  folder["path"] : full_path =  folder["path"]
                    #if it's a folder add as a child folder
                    parent.child_folders.create!(name: folder["path"], path: full_path,
                        parent: parent.path) unless parent.child_folders.find_by(path: full_path)
                    #recursively call to get the children of this folder
                    list(parent.child_folders.find_by(path: full_path), depth+1)
                else
                    ##if it's a file add it as a user_file unless it exists already
                    parent.user_files.create!(name: folder["path"].tr("/", ""), path: parent.path + folder["path"].tr("/",""),
                        parent: parent.path) unless parent.user_files.find_by(path: parent.path + folder["path"].tr("/",""))
                end
            end
        end
        ##when recursion is over
        if (depth == 0)
            flash[:success] = "Files have been listed (Check console)"
            redirect_to "/"
        end
    end

    def download
        puts @client.get_file("/Public/factorial.txt")
        puts "---------------------------------------------"
        flash[:success] = "Downloading (Check console)"
        redirect_to "/"
    end

  private

    def get_web_auth
        return DropboxOAuth2Flow.new(Rails.application.secrets.dropbox_key, Rails.application.secrets.dropbox_secret, dropbox_callback_url, session, :dropbox_auth_csrf_token)
    end

    def create_client
        @client = DropboxClient.new(current_user.services.find_by(name: "Dropbox").access_token) if (current_user.services.find_by(name: "Dropbox"))
        puts "-------------------------------------------------"
        puts "Linked account:", @client.account_info().inspect
        puts "-------------------------------------------------"
    end

end
