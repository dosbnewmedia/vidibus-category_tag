# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

require 'vidibus/category_tag/version'

Gem::Specification.new do |s|
  s.name        = 'vidibus-category_tag'
  s.version     = Vidibus::CategoryTag::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Martin Jagusch, Andre Pankratz']
  s.email       = ['async@mj.io', 'andre@vidibus.com']
  s.homepage    = 'https://github.com/vidibus/vidibus-category_tag'
  s.summary     = 'Tags organized in categories for Mongoid documents.'
  s.description = s.summary
  s.license     = 'MIT'

  s.add_dependency 'activesupport', '>= 3.0'
  s.add_dependency 'mongoid', '>= 3'
  s.add_dependency 'vidibus-uuid', '1.0.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rdoc'

  s.files = Dir.glob('{lib,app,config}/**/*') + %w(LICENSE README.md Rakefile)
  s.require_path = 'lib'
end
