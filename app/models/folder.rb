class Folder
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :path, type: String
  field :parent, type: String

  validates :name, presence: true

  embedded_in :users
  recursively_embeds_many
  embeds_many :user_files
end
