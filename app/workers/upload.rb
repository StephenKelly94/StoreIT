class Upload
  include Sidekiq::Worker
  require 'dropbox_sdk'
  require 'rest-client'

  def perform(service, access_token, path, tmpPath)

    if(service === "dropbox")
        file = File.absolute_path(tmpPath)
        client = DropboxClient.new(access_token)
        client.put_file(path, File.read(file))
    elsif (service === "onedrive")
        file = File.absolute_path(tmpPath)
        RestClient::Request.execute(method: "put", url: "https://api.onedrive.com/v1.0#{path}:/content", payload: File.read(file),
                                    headers: {Authorization: "Bearer #{access_token}", content_type: "application/octet-stream"})
    elsif (service === "googledrive")
    end
    File.delete(tmpPath) if File.exist?(tmpPath)
  end
end
