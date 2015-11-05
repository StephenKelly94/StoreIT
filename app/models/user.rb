class User
  include Mongoid::Document
  include ActiveModel::SecurePassword
  
  field :name, type: String
  field :email, type: String
  field :password, type: String
  field :password_digest, type: String
  has_secure_password
  field :account_created, type: Time
end
