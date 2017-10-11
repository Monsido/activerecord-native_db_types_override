## ActiveRecord 4.x Native Database Types Override

Define native database types and change default migration behavior in ActiveRecord/Rails.

### Setup

In your ActiveRecord/Rails 4.x project, add this to your Gemfile:

    gem 'activerecord-native_db_types_override'

Then run:

    bundle install

### Usage

Define configuration to be run prior to migration execution, such as in a Rails initializer or environment file.

#### Configure Adapters

The following symbols can be used can be used with the NativeDbTypesOverride.configure_adapters method to automatically require and load the right adapter class prior to configuring it:

Adapters included in ActiveRecord:
* [:postgres](https://github.com/rails/rails/blob/4-2-stable/activerecord/lib/active_record/connection_adapters/postgresql_adapter.rb)
* [:mysql](https://github.com/rails/rails/blob/4-2-stable/activerecord/lib/active_record/connection_adapters/abstract_mysql_adapter.rb)
* [:sqlite](https://github.com/rails/rails/blob/4-2-stable/activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb)

Adapters that require other gems:
* [:oracle_enhanced](https://github.com/rsim/oracle-enhanced/blob/release16/lib/active_record/connection_adapters/oracle_enhanced_adapter.rb)
* [:sqlserver](https://github.com/rails-sqlserver/activerecord-sqlserver-adapter/blob/4-2-stable/lib/active_record/connection_adapters/sqlserver_adapter.rb)

You can also specify a custom adapter class that uses a native_database_types method to map types. See 'Other Adapters' for more information.

#### PostgreSQL

The following would:
* use primary key type 'bigserial primary key' for in migrations
* change add_reference behavior in migrations to use bigint type by default
* use timestamptz for all datetimes and timestamps created by migrations* 

    NativeDbTypesOverride.configure_adapters({
      postgres: {
        datetime: { name: "timestamptz" },
        timestamp: { name: "timestamptz" },
        primary_key: { name: "bigserial primary key"}
      }
    })

    NativeDbTypesOverride.configure_migrations({
      add_reference: {type: :bigint}
    })

See PostgreSQLAdapter source for the default types.

#### MySQL

For the MySQL/MySQL2 adapters, maybe you could change boolean to a string type:

    NativeDbTypesOverride.configure_adapters({
      mysql: {
        boolean: { name: "varchar", limit: 1 }
      }
    })

Alternatively, you could use the this Gem to override [primary_key](https://github.com/rails/rails/blob/master/activerecord/lib/active_record/connection_adapters/abstract_mysql_adapter.rb#L43)  to overcome errors that occur when trying to run `rake db:migrate` that are caused by MySQL updates (i.e. MySQL 5.7) that no longer support DEFAULT NULL values for PRIMARY KEY. Simply create the following:

*config/initializers/abstract_mysql2_adapter.rb*

	require 'active_record/connection_adapters/mysql2_adapter'
	NativeDbTypesOverride.configure_adapters({
	  ActiveRecord::ConnectionAdapters::Mysql2Adapter => {
	    primary_key: "int(11) auto_increment PRIMARY KEY"
	  }
	})

*config/environment.rb*

	# Load monkey patches to prevent migration errors after importing legacy sql dumpfile
	require File.expand_path('../initializers/abstract_mysql2_adapter.rb', __FILE__)

*config/database.yml* check contains 'adapter: mysql2' for db connection to be used

See [AbstractMysqlAdapter][mysql_adapter] for the default types. (Change code branch as needed.)

#### SQLite3

Maybe you need to extend the default string limit from 255 to 4096:

    NativeDbTypesOverride.configure_adapters({
      sqlite: {
        string: { :name: "varchar", limit: 4096 }
      }
    })

See [SQLite3Adapter][sqlite_adapter] for the default types. (Change code branch as needed.)

#### Oracle

Oracle enhanced adapter isn't included in Rails, so you have to include its gem in your Gemfile along with any other requirements it has.

In addition, it's native_database_types method can define boolean as VARCHAR2 (1 char) or NUMBER (0 or 1), so if that is all you are trying to do, then *don't use this gem* and just try this or look in its adapter/README to see how this could be done:

    ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.emulate_booleans_from_strings = true

However, if you need to make another change like making datetime and timestamp store timezones *and* you want to emulate_booleans_from_strings, just ensure that you define the boolean shown in the following example rather than using OracleEnhancedAdapter's emulate_booleans_from_strings option:

    NativeDbTypesOverride.configure_adapters({
      oracle: {
        datetime: { name: "TIMESTAMP WITH TIMEZONE" },
        timestamp: { name: "TIMESTAMP WITH TIMEZONE" },
        boolean: { name: "VARCHAR2", limit: 1 }
      }
    })

The reason for this is that Native Database Types Override gem tries to use the constant NATIVE_DATABASE_TYPES available on most adapters to get the existing hash before doing the overrides, but OracleEnhancedAdapter's emulate_booleans_from_strings option changes what is returned by the native_database_types method to NATIVE_DATABASE_TYPES but with :boolean changed to the value {:name => "VARCHAR2", :limit => 1}.

See oracle_enhanced_adapter link below for the default types.

#### Other Adapters

ActiveRecord adapter class that uses a `native_database_types` method to define the type mappings (as most do) should work. Just specify the fully-qualified name (e.g. ActiveRecord::ConnectionAdapters::MyDbAdapter) as the key in the options hash.

Be sure to add a require for the adapter, if it has not been loaded already prior to configuration, e.g.:

    require 'active_record/connection_adapters/postgresql_adapter'
    NativeDbTypesOverride.configure_adapters({
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter => {
        datetime: { name: "timestamptz" },
        timestamp: { name: "timestamptz" }
      }
    })


### Troubleshooting

Turn on debug output:

    NativeDbTypesOverride.debug = true

If not using one of the supported symbols you may need to add a require for the adapter before the configuration or you may get an `uninitialized constant (adapter class)` error, depending on whether something else loaded the adapter prior.

Test out a migration and include all the types defined in your adapter's NATIVE_DATABASE_TYPES if you're unsure whether it is defining things correctly, e.g.:

    rails g model MyModel a_string:string a_text:text an_integer:integer a_float:float a_decimal:decimal a_datetime:datetime a_timestamp:timestamp a_time:time a_date:date a_binary:binary a_boolean:boolean a_xml:xml a_tsvector:tsvector
    rake db:migrate

With Rails you can output the schema to see if the types were set correctly:

    rake db:structure:dump

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

### Contributors

* Gary Weaver (https://github.com/garysweaver)

### License

(c) 2012-2014 FineLine Prototyping, Inc., (c) 2016-2017 Proto Labs, Inc., released under the [MIT license][lic].

[lic]: LICENSE
