class StaticPagesController < ApplicationController
  def home
  	if current_user
        if dropbox_root = Folder.roots.find_by(name: "Dropbox_Root")
  		    @dropbox_root = dropbox_root
        end
        if onedrive_root = Folder.roots.find_by(name: "Onedrive_Root")
            @onedrive_root = onedrive_root
        end
        if googledrive_root = Folder.roots.find_by(name: "Googledrive_Root")
            @googledrive_root = googledrive_root
        end
  	end
  end

  def about
  end
end
