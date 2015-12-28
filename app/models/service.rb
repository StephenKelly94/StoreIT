class Service
  include Mongoid::Document
  field :name, type: String
  field :access_token, type: String

  embedded_in :user

  def remove
      self.name = nil
      self.access_token = nil
  end
end
