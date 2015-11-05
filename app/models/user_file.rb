class UserFile
  include Mongoid::Document
  field :name, type: String
  field :path, type: String
end
