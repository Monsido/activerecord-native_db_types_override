module NativeDbTypesOverride
  class AdapterOverrider

    def self.override_native_database_types(adapter_class, hash)
      puts "ActiveRecord - Native Database Types Override #{NativeDbTypesOverride::VERSION}" if NativeDbTypesOverride.debug?
      new_types = {}
      begin
        new_types = adapter_class.const_get('NATIVE_DATABASE_TYPES')
      rescue
        puts "No NATIVE_DATABASE_TYPES constant on #{adapter_class} so expecting the whole types hash to be specified via NativeDbTypesOverride.configure()" if NativeDbTypesOverride.debug?
      end
      new_types = new_types.merge(hash)
      puts "Defining #{adapter_class}.native_database_types as #{new_types.inspect}" if NativeDbTypesOverride.debug?

      adapter_class.class_eval "def native_database_types; #{new_types.inspect}; end"
    end

    def self.convert_symbol_to_class(adapter_class_or_sym)
      case adapter_class_or_sym
      when :postgres
        require 'active_record/connection_adapters/postgresql_adapter'
        '::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'.constantize
      when :mysql
        require 'active_record/connection_adapters/abstract_mysql_adapter'
        '::ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter'.constantize
      when :sqlite
        require 'active_record/connection_adapters/sqlite3_adapter'
        '::ActiveRecord::ConnectionAdapters::SQLite3Adapter'.constantize
      when :oracle
        require 'active_record/connection_adapters/oracle_enhanced_adapter'
        '::ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter'.constantize
      when :sqlserver
        require 'active_record/connection_adapters/sqlserver_adapter'
        '::ActiveRecord::ConnectionAdapters::SQLServer'.constantize
      else
        adapter_class_or_sym
      end
    end
  end
end
