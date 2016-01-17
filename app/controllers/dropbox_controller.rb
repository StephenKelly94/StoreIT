class DropboxController < ApplicationController
    require 'dropbox_sdk'
    require 'json'


    before_action :create_client, only: [:list, :download]

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
            Folder.create(name: "Dropbox_Root", folder_path: "/") unless current_user.folders.find_by(name: "Dropbox_Root")
            flash[:success] = "You have successfully authorized dropbox."
        else
            flash[:error] = "Already authenticated"
        end
        create_client
        get_folders
        redirect_to root_path

    end


    def list
        #A hash of the folders for next three levels. Format is
        #folders[folder_name] = child files/folders
        @folders = get_folders
        flash[:success] = "Files have been listed (Check console)"
        redirect_to root_path
    end

    def download
        puts @client.get_file("/Public/factorial.txt")
        puts "---------------------------------------------"
        flash[:success] = "Downloading (Check console)"
        redirect_to root_path
    end

  private

    #Returns a hash files/folders in a given parent folder (default is root folder)
    #Depth is also provided for effiency to load only three levels (default is 0)
    #If there's no hash or array given create a new one
    def get_folders(parent = Folder.roots.find_by(name: "Dropbox_Root"), depth = 0, child_folders = Hash.new{}, array = [])
        if depth < 3
            puts "============================"
            puts parent.folder_path
            folders = @client.metadata(parent.folder_path)

            #Iterates through the contents (where the children of the folder are stored)
            folders["contents"].each do |folder|
                if(folder["is_dir"])

                    full_path =  folder["path"]

                    #Taken by substituting the path of the parent from the path of the
                    #folder given by dropbox.
                    name = full_path.sub(parent.folder_path, "")


                    #if it's a folder add as a child folder
                    parent.children.create(name: name, folder_path: full_path) unless parent.children.find_by(folder_path: full_path)

                    #Add it to folders hash, with it's depth as key, and an array of the folders as the value
                    child_folders[parent.name] = array  << parent.children.find_by(folder_path: full_path).name

                    #recursively call to get the children of this folder
                    get_folders(parent.children.find_by(folder_path: full_path), depth+1, child_folders)
                else
                    ##if it's a file add it as a user_file unless it exists already
                    parent.user_files.create(name: folder["path"].tr("/", ""), folder_path: parent.folder_path + folder["path"].tr("/",""),
                        parent: parent.folder_path) unless parent.user_files.find_by(folder_path: parent.folder_path + folder["path"].tr("/",""))

                    #Add the file to the hash
                    child_folders[parent.name] = array  << parent.user_files.find_by(folder_path: parent.folder_path + folder["path"].tr("/","")).name
                end
            end
        end
        child_folders if depth == 0
    end

    #Create the url for ouath authentication
    def get_web_auth
        return DropboxOAuth2Flow.new(Rails.application.secrets.dropbox_key, Rails.application.secrets.dropbox_secret, dropbox_callback_url, session, :dropbox_auth_csrf_token)
    end

    #Creates a new client
    def create_client
        @client = DropboxClient.new(current_user.services.find_by(name: "Dropbox").access_token) if (current_user.services.find_by(name: "Dropbox"))
        puts "-------------------------------------------------"
        puts "Linked account:", @client.account_info().inspect
        puts "-------------------------------------------------"
    end

end
