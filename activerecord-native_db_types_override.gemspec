# -*- encoding: utf-8 -*-  
$:.push File.expand_path("../lib", __FILE__)  
require "activerecord-native_db_types_override/version" 

Gem::Specification.new do |s|
  s.name        = 'activerecord-native_db_types_override'
  s.version     = NativeDbTypesOverride::VERSION
  s.authors     = ['Gary S. Weaver']
  s.email       = ['garysweaver@gmail.com']
  s.homepage    = 'https://github.com/FineLinePrototyping/activerecord-native_db_types_override'
  s.summary     = %q{Overrides native database types in ActiveRecord DB adapters.}
  s.description = %q{Overrides native database types for any database adapter with a native_database_types method. Compatible with ActiveRecord 3.1+/4.0.}
  s.files = Dir['lib/**/*'] + ['Rakefile', 'README.md']
  s.license = 'MIT'
end
