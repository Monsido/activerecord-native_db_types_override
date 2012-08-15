ActiveRecord 3.1+/4.0 Native Database Types Override
=====

Define native database types that Rails migrations and ActiveRecord should use. Theoretically this should work for any ActiveRecord adapter written to support the access defined in the "How it works" section.

Does not work in Rails/ActiveRecord 3.0 or earlier versions, and even though it should work in Rails/ActiveRecord 3.1+/4.0.

### How it works

All adapter classes in Rails 3.1-4.0 should have a NATIVE_DATABASE_TYPES constant and a native_database_types method that can be redefined, so we get the NATIVE_DATABASE_TYPES if it exists, if not we start with an empty hash. Then we merge in your settings, and redefine the native_database_types instance method (defined at class level so using class_eval) to return the value of inspect from the merged hash.

### Setup

In your ActiveRecord/Rails 3.1+ project, add this to your Gemfile:

    gem 'activerecord-native_db_types_override', :git => 'git://github.com/garysweaver/activerecord-native_db_types_override.git'

Then run:

    bundle install

To stay up-to-date, periodically run:

    bundle update activerecord-native_db_types_override

### Usage

In your config/environment.rb or environment specfic configuration, you may specify one or more options in the config hash that will be merged into the default types. The act of configuring does the hash merge/activation of changes.

#### PostgreSQL

For example, if you want Rails to use the timestamptz type for all datetimes and timestamps created by migrations, you could use:

    NativeDbTypesOverride::Options.configure({
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter => {
        :datetime => { :name => "timestamptz" },
        :timestamp => { :name => "timestamptz" }
      }
    })

See [PostgreSQLAdapter][postgres_adapter] for the default types.

#### MySQL

For the MySQL/MySQL2 adapters, maybe you could change boolean to a string type:

    require 'native_db_types_override'
    NativeDbTypesOverride::Options.configure({
      ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter => {
        :boolean => { :name => "varchar", :limit => 1 }
      }
    })

See [AbstractMysqlAdapter][mysql_adapter] for the default types.

#### SQLite3

Maybe you need to extend the default string limit from 255 to 4096:

    require 'native_db_types_override'
    NativeDbTypesOverride::Options.configure({
      ActiveRecord::ConnectionAdapters::SQLite3Adapter => {
        :string => { :name => "varchar", :limit => 4096 }
      }
    })

See [SQLite3Adapter][sqlite_adapter] for the default types.

#### Oracle

Oracle enhanced adapter isn't included in Rails, so you have to include its gem.

In addition, it's native_database_types method can define boolean as VARCHAR2 (1 char) or NUMBER (0 or 1), so if that is all you are trying to do, then *don't use this gem* and just try this or look in its adapter/README to see how this could be done:

    ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.emulate_booleans_from_strings = true

However, if you need to make another change like making datetime and timestamp store timezones *and* you want to emulate_booleans_from_strings, you'll need to do that manually:

    require 'native_db_types_override'
    NativeDbTypesOverride::Options.configure({
      ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter => {
        :datetime => { :name => "TIMESTAMP WITH TIMEZONE" },
        :timestamp => { :name => "TIMESTAMP WITH TIMEZONE" },
        :boolean     => { :name => "NUMBER", :limit => 1 }
      }
    })

The reason for this is that Native Database Types Override tries to use the constant NATIVE_DATABASE_TYPES available on most adapters to get the existing hash before doing the overrides.

See [OracleEnhancedAdapter][oracle_adapter] for the default types.

#### Others

Look for the adapter class that contains the native_database_types method and specify the fully-qualified name (e.g. ActiveRecord::ConnectionAdapters::MyDbAdapter) as the key in the options hash. Let us know if we can list your adapter here.

### Troubleshooting

Test out a migration and include all the types defined in your adapter's NATIVE_DATABASE_TYPES if you're unsure whether it is defining things correctly, e.g. in a test project for PostgreSQL in Rails 3.1/3.2 you could do this and then look at the my_models table in your database:

    rails g model MyModel a_string:string a_text:text an_integer:integer a_float:float a_decimal:decimal a_datetime:datetime a_timestamp:timestamp a_time:time a_date:date a_binary:binary a_boolean:boolean a_xml:xml a_tsvector:tsvector
    rake db:migrate

Then just to ensure it really is working, go into rails console:

    rails c

And try to play with data (this is postgres-specific):

    MyModel.all
    m = MyModel.new
    m.a_string = 'test make this string as long as the limit'
    m.an_integer = 12345678
    m.a_float = 1.2345789
    m.a_decimal = 1.2345789
    m.a_datetime = Time.now
    m.a_timestamp = Time.now
    m.a_time = Time.now
    m.a_date = Time.now
    m.a_binary = 1
    m.a_boolean = true
    m.a_xml = '<testing>123</testing>'
    #m.a_tsvector = nil # TODO: need an example of how to set with sample data
    m.save!

### License

Copyright (c) 2012 Gary S. Weaver, released under the [MIT license][lic].

[postgres_adapter]: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/connection_adapters/postgresql_adapter.rb
[mysql_adapter]: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/connection_adapters/abstract_mysql_adapter.rb
[sqlite_adapter]: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb
[oracle_adapter]: https://github.com/rsim/oracle-enhanced/blob/master/lib/active_record/connection_adapters/oracle_enhanced_adapter.rb
[lic]: http://github.com/garysweaver/activerecord-native_db_types_override/blob/master/LICENSE
