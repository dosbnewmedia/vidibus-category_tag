class TagObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Vidibus::Uuid::Mongoid

  embedded_in :tag_category

  field :value, type: String

  validates :value, :presence => true
end
