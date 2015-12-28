class DropboxController < ApplicationController
    require 'dropbox_sdk'
    require 'json'


    def authorize
        authorize_url = get_web_auth.start()
        redirect_to authorize_url
        #dbsession = DropboxSession.new(Rails.application.secrets.dropbox_key, Rails.application.secrets.dropbox_secret)
        #serialize and save this DropboxSession
        #session[:dropbox_session] = dbsession.serialize
        #pass to get_authorize_url a callback url that will return the user here
        #redirect_to dbsession.get_authorize_url url_for(:action => 'dropbox_callback')
    end

    def deauthorize
        current_user.services.find_by(name: "Dropbox").delete
        flash[:success] = "You have successfully deauthorized dropbox."
        redirect_to "/"
    end

    def dropbox_callback
        access_token, user_id, url_state = get_web_auth.finish(params)
        current_user.services.create!(name: "Dropbox", access_token: access_token) unless (current_user.services.find_by(name: "Dropbox"))
        flash[:success] = "You have successfully authorized dropbox."
        redirect_to "/"
        # dbsession = DropboxSession.deserialize(session[:dropbox_session])
        # @access_token = dbsession.get_access_token #we've been authorized, so now request an access_token
        # session[:dropbox_session] = dbsession.serialize
        # current_user.services.create!(name: "Dropbox", access_token: @access_token, session: session[:dropbox_session]))
        # session.delete :dropbox_session
        # flash[:success] = "You have successfully authorized with dropbox."
        # redirect_to "/"
    end

    def list
        client = create_client
        puts "Linked account:", client.account_info().inspect
        puts "-------------------------------------------------"
        puts "Metadata:", JSON.pretty_generate(client.metadata('/public'))
        puts "-------------------------------------------------"
        flash[:success] = "Files have been listed (Check console)"
        redirect_to "/"
    end

    def download
        client = create_client
        puts client.get_file("/Public/factorial.txt")
        puts "---------------------------------------------"
        flash[:success] = "Downloading (Check console)"
        redirect_to "/"
    end

  private

    def get_web_auth
        return DropboxOAuth2Flow.new(Rails.application.secrets.dropbox_key, Rails.application.secrets.dropbox_secret, dropbox_callback_url, session, :dropbox_auth_csrf_token)
    end

    def create_client
        return DropboxClient.new(current_user.services.find_by(name: "Dropbox").access_token) if (current_user.services.find_by(name: "Dropbox"))
    end

end
