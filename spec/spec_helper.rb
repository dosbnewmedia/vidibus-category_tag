require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

$:.unshift File.expand_path('../../app', __FILE__)

require 'rspec'
require 'factory_bot'
require 'vidibus-uuid'

require 'vidibus-category_tag'
require 'models/tag_category'
require 'factories'

Mongo::Logger.logger.level = Logger::FATAL

Mongoid.configure do |config|
  config.connect_to('vidibus-category_tag_test')
end

RSpec.configure do |config|
  config.before(:each) do
    Mongoid::Clients.default.collections.
      select {|c| c.name !~ /system/}.each(&:drop)
  end
end