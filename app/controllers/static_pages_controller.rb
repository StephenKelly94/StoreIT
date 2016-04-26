class StaticPagesController < ApplicationController
  def home
  	if current_user
        dropbox_root = Folder.roots.where(name: "Dropbox_Root", user_id: current_user.id)
        onedrive_root = Folder.roots.find_by(name: "Onedrive_Root", user_id: current_user.id)
        googledrive_root = Folder.roots.find_by(name: "Googledrive_Root", user_id: current_user.id)
        if dropbox_root.first
            @dropbox_root = dropbox_root.first.id
        end
        if onedrive_root
            @onedrive_root = onedrive_root.id
        end
        if googledrive_root
            @googledrive_root = googledrive_root.id
        end
  	end
  end

  def about
  end
end
