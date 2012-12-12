ActiveRecord 3.1+/4.0 Native Database Types Override
=====

Define native database types that Rails migrations and ActiveRecord should use. Theoretically this should work for any ActiveRecord adapter written to support the access defined in the "How it works" section.

Does not work in Rails/ActiveRecord 3.0 or earlier versions, and even though it should work in Rails/ActiveRecord 3.1+/4.0.

### How it works

All adapter classes in Rails 3.1-4.0 should have a NATIVE_DATABASE_TYPES constant and a native_database_types method that can be redefined, so we get the NATIVE_DATABASE_TYPES if it exists, if not we start with an empty hash. Then we merge in your settings, and redefine the native_database_types instance method (defined at class level so using class_eval) to return the value of inspect from the merged hash.

### Setup

In your ActiveRecord/Rails 3.1+ project, add this to your Gemfile:

    gem 'activerecord-native_db_types_override'

Then run:

    bundle install

### Usage

In your config/environment.rb or an environment specific configuration, you may specify one or more options in the config hash that will be merged into the default types. The act of configuring does the hash merge/activation of changes.

Some gems may require the adapter prior to this point, so it may not need to be required, but we do not load the Rails adapters in the NativeDbTypesOverride gem because all are most likely not needed.

Note: I left the Ruby 1.8 hashrocket notation to show it shouldn't matter. Feel free to use 1.9+ hash syntax.

#### PostgreSQL

For example, if you want Rails to use the timestamptz type for all datetimes and timestamps created by migrations, you could use:

    require 'active_record/connection_adapters/postgresql_adapter'
    NativeDbTypesOverride.configure({
      :postgres => {
        :datetime => { :name => "timestamptz" },
        :timestamp => { :name => "timestamptz" }
      }
    })

See [PostgreSQLAdapter][postgres_adapter] for the default types.

#### MySQL

For the MySQL/MySQL2 adapters, maybe you could change boolean to a string type:

    NativeDbTypesOverride.configure({
      :mysql => {
        :boolean => { :name => "varchar", :limit => 1 }
      }
    })

See [AbstractMysqlAdapter][mysql_adapter] for the default types.

#### SQLite3

Maybe you need to extend the default string limit from 255 to 4096:

    NativeDbTypesOverride.configure({
      :sqlite => {
        :string => { :name => "varchar", :limit => 4096 }
      }
    })

See [SQLite3Adapter][sqlite_adapter] for the default types.

#### Oracle

Oracle enhanced adapter isn't included in Rails, so you have to include its gem in your Gemfile along with any other requirements it has.

In addition, it's native_database_types method can define boolean as VARCHAR2 (1 char) or NUMBER (0 or 1), so if that is all you are trying to do, then *don't use this gem* and just try this or look in its adapter/README to see how this could be done:

    ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.emulate_booleans_from_strings = true

However, if you need to make another change like making datetime and timestamp store timezones *and* you want to emulate_booleans_from_strings, just ensure that you define the boolean shown in the following example rather than using OracleEnhancedAdapter's emulate_booleans_from_strings option:

    NativeDbTypesOverride.configure({
      :oracle => {
        :datetime => { :name => "TIMESTAMP WITH TIMEZONE" },
        :timestamp => { :name => "TIMESTAMP WITH TIMEZONE" },
        :boolean => { :name => "VARCHAR2", :limit => 1 }
      }
    })

The reason for this is that Native Database Types Override gem tries to use the constant NATIVE_DATABASE_TYPES available on most adapters to get the existing hash before doing the overrides, but OracleEnhancedAdapter's emulate_booleans_from_strings option changes what is returned by the native_database_types method to NATIVE_DATABASE_TYPES but with :boolean changed to the value {:name => "VARCHAR2", :limit => 1}.

See [OracleEnhancedAdapter][oracle_adapter] for the default types.

#### Others

Look for the adapter class that contains the `native_database_types` method and specify the fully-qualified name (e.g. ActiveRecord::ConnectionAdapters::MyDbAdapter) as the key in the options hash.

Be sure to add a require for the adapter, if it has not been loaded already prior to configuration, e.g.:

    require 'active_record/connection_adapters/postgresql_adapter'
    NativeDbTypesOverride.configure({
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter => {
        :datetime => { :name => "timestamptz" },
        :timestamp => { :name => "timestamptz" }
      }
    })

Let us know if we can add support for an adapter, so it can be referenced by a symbol instead. Pull requests welcome!

### Troubleshooting

If not using one of the supported symbols you may need to add a require for the adapter before the configuration or you may get an `uninitialized constant (adapter class)` error, depending on whether something else loaded the adapter prior.

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
    m.a_tsvector = nil
    m.save!

Turn on debug output by adding this prior to NativeDbTypesOverride.configure:

    NativeDbTypesOverride.debug = true

### License

Copyright (c) 2012 Gary S. Weaver, released under the [MIT license][lic].

[postgres_adapter]: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/connection_adapters/postgresql_adapter.rb
[mysql_adapter]: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/connection_adapters/abstract_mysql_adapter.rb
[sqlite_adapter]: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb
[oracle_adapter]: https://github.com/rsim/oracle-enhanced/blob/master/lib/active_record/connection_adapters/oracle_enhanced_adapter.rb
[lic]: http://github.com/garysweaver/activerecord-native_db_types_override/blob/master/LICENSE
