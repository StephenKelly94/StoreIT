json.array!(@users) do |user|
  json.extract! user, :id, :name, :email, :password, :account_created
  json.url user_url(user, format: :json)
end
