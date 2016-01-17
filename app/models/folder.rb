class Folder
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Ancestry

  field :name, type: String
  field :folder_path, type: String

  validates :name, presence: true

  belongs_to :users
  embeds_many :user_files

  #To make it a tree. See: https://github.com/skyeagle/mongoid-ancestry
  has_ancestry

end
