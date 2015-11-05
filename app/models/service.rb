class Service
  include Mongoid::Document
  field :name, type: String
  field :app_key, type: String
  field :app_secret, type: String
end
