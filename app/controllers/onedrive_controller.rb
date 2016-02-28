class OnedriveController < ApplicationController
	require 'oauth2'
	require 'rest-client'
	require 'json'
	def authorize
		client = OAuth2::Client.new(Rails.application.secrets.onedrive_key,
	                                Rails.application.secrets.onedrive_secret,
	                                :site => 'https://login.live.com',
	                                :authorize_url => '/oauth20_authorize.srf',
	                                :token_url => '/oauth20_token.srf')
		token = client.auth_code.get_token(params[:code], :redirect_uri => onedrive_authorize_url)
		response = RestClient.get "https://api.onedrive.com/v1.0/drive/root", {:Authorization => "Bearer #{token.token}"}
		puts "======================================="
		puts JSON.pretty_generate(JSON.parse(response))
		flash[:success] = "Files listed check console"
		redirect_to root_path
	end
end
