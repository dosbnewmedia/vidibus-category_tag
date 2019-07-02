require 'vidibus-uuid'
FactoryBot.define do
  factory :tag_category do
    # uuid { SecureRandom.uuid.gsub!('-') }
    label { 'Genre' }
  end
end
