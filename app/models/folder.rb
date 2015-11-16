class Folder
  include Mongoid::Document
  field :name, type: String
  field :path, type: String
  field :parent, type: String

  validates :name, presence: true

  belongs_to :user
  belongs_to :service
  embedded_in :folder
  embeds_many :folders
  embeds_many :user_files
end
