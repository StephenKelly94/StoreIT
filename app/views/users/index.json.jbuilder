json.array!(@users) do |user|
  json.extract! user, :id, :email, :services
  json.url user_url(user, format: :json)
end
