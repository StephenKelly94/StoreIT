class Folder
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Ancestry

  field :name, type: String
  field :folder_path, type: String
  field :dirty_flag, type: String

  validates :name, presence: true

  belongs_to :user
  embeds_many :user_files

  #To make it a tree. See: https://github.com/skyeagle/mongoid-ancestry
  has_ancestry


  #Change mongoid's id to return id string instead of object, for React
  #Found: http://stackoverflow.com/questions/23595519/return-mongoid-object-as-json
  def as_json(*args)
    res = super
    res["id"] = res["_id"].to_s
    res
  end

end
