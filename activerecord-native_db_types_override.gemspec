# -*- encoding: utf-8 -*-  
$:.push File.expand_path("../lib", __FILE__)  
require "activerecord-native_db_types_override/version" 

Gem::Specification.new do |s|
  s.name        = 'activerecord-native_db_types_override'
  s.version     = NativeDbTypesOverride::VERSION
  s.authors     = ['Gary S. Weaver']
  s.email       = ['garysweaver@gmail.com']
  s.homepage    = 'https://github.com/garysweaver/activerecord-native_db_types_override'
  s.summary     = %q{Define native database types and change default migration behavior.}
  s.description = %q{Define native database types and change default migration behavior in ActiveRecord/Rails.}
  s.files = Dir['lib/**/*'] + ['Rakefile', 'README.md']
  s.license = 'MIT'
end
