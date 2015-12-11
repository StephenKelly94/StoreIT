class Service
  include Mongoid::Document
  field :name, type: String
  field :app_key, type: String
  field :app_secret, type: String

  has_and_belongs_to_many :users
end
