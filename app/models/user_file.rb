class UserFile
  include Mongoid::Document
  field :name, type: String
  field :path, type: String
  field :parent, type: String
  validates :name, presence: true

  embedded_in :folder
  belongs_to :service
end
