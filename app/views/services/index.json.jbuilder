json.array!(@services) do |service|
  json.extract! service, :id, :name, :app_key, :app_secret
  json.url service_url(service, format: :json)
end
