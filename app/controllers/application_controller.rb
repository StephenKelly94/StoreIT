class ApplicationController < ActionController::Base

    require 'json'
	require 'oauth2'
	require 'rest-client'
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery

    def rest_call(url, verb="get", payload=nil, contentType="json")
        verb === "delete" ? RestClient::Request.execute(method: verb, url: url, payload: payload, headers: {Authorization: "Bearer #{@token}", content_type: contentType}) :
              JSON.parse(RestClient::Request.execute(method: verb, url: url, payload: payload, headers: {Authorization: "Bearer #{@token}", content_type: contentType}))
    end
end
