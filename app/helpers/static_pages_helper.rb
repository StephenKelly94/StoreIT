module StaticPagesHelper
	def get_onedrive_login
		client = OAuth2::Client.new(Rails.application.secrets.onedrive_key,
	                                Rails.application.secrets.onedrive_secret,
	                                :site => 'https://login.live.com',
	                                :authorize_url => '/oauth20_authorize.srf',
	                                :token_url => '/oauth20_token.srf')
		login_url =  client.auth_code.authorize_url(:redirect_uri => onedrive_authorize_url, :scope => "onedrive.readwrite")
	end

end
