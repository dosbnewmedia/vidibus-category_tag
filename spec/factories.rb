require 'vidibus-uuid'
FactoryBot.define do
  factory :tag_category do
    # uuid { SecureRandom.uuid.gsub!('-') }
    label { 'Genre' }
  end

  factory :tag_object do
    value { 'Tag' }
  end
end
