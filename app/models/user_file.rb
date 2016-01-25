class UserFile
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :folder_path, type: String
  field :parent, type: String

  validates :name, presence: true

  embedded_in :folder

  #Change mongoid's id to return id string instead of object, for React
  #Found: http://stackoverflow.com/questions/23595519/return-mongoid-object-as-json
  def as_json(*args)
    res = super
    res["id"] = res["_id"].to_s
    res
  end

end
