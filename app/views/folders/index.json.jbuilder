json.array!(@folders) do |folder|
  json.extract! folder, :id, :name, :path
  json.url folder_url(folder, format: :json)
end
