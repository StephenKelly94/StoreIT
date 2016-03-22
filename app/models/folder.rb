class Folder
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Ancestry

  field :name, type: String
  field :service_folder_id, type: String
  field :folder_path, type: String
  field :dirty_flag, type: String

  validates :name, presence: true

  belongs_to :user
  embeds_many :user_files

  #To make it a tree. See: https://github.com/skyeagle/mongoid-ancestry
  has_ancestry

  def self.id_to_service_id(folder_id)
      Folder.find(folder_id).service_folder_id
  end
end
