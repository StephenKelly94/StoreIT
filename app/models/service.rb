class Service
  include Mongoid::Document
  field :name, type: String
  field :access_token, type: String
  field :used_space, type: Integer
  field :total_space, type: Integer

  embedded_in :user

  def remove
      self.name = nil
      self.access_token = nil
      self.used_space = nil
      self.total_space = nil
  end
end
