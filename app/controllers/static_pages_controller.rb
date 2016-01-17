class StaticPagesController < ApplicationController
  def home
  	dropbox_root = Folder.roots.find_by(name: "Dropbox_Root")
  	if((current_user) && (dropbox_root))
  		@dropbox_root = dropbox_root
  	end
  end

  def about
  end
end
