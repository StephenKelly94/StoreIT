class UserFile
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :folder_path, type: String
  field :parent, type: String

  validates :name, presence: true

  embedded_in :folder
end
