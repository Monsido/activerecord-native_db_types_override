module NativeDbTypesOverride
  class << self
    attr_accessor :debug

    def debug?
      !!send(:debug)
    end
    
    def configure(hash)
      puts "ActiveRecord - Native Database Types Override #{NativeDbTypesOverride::VERSION}" if NativeDbTypesOverride.debug?
      hash.keys.each do |key|
        begin
          clazz = convert_symbol_to_class(key)
        rescue => e
          puts "Unable to get adapter class for #{key.inspect}. Try specifying the adapter class itself as the key in the hash in NativeDbTypesOverride.configure(). Error: #{e.message}\n#{e.backtrace.join("\n")}"
        end
        new_types = {}
        begin
          new_types = clazz.const_get('NATIVE_DATABASE_TYPES')
        rescue
          puts "No NATIVE_DATABASE_TYPES constant on #{clazz} so expecting the whole types hash to be specified via NativeDbTypesOverride.configure()" if NativeDbTypesOverride.debug?
        end
        new_types = new_types.merge(hash[key])
        puts "Defining #{clazz}.native_database_types as #{new_types.inspect}" if NativeDbTypesOverride.debug?
        clazz.class_eval "def native_database_types; #{new_types.inspect}; end"
      end
    end

    private

    def convert_symbol_to_class(clazz)
      case clazz
      when :postgres
        require 'active_record/connection_adapters/postgresql_adapter'
        'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'.constantize
      when :mysql
        require 'active_record/connection_adapters/abstract_mysql_adapter'
        'ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter'.constantize
      when :sqlite
        require 'active_record/connection_adapters/sqlite3_adapter'
        'ActiveRecord::ConnectionAdapters::SQLite3Adapter'.constantize
      when :oracle
        require 'active_record/connection_adapters/oracle_enhanced_adapter'
        'ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter'.constantize
      else
        clazz
      end
    end
  end
end
