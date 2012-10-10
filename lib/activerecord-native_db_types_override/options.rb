module NativeDbTypesOverride
  class << self
    attr_accessor :debug

    def debug?
      !!send(:debug)
    end
    
    def configure(hash)
      puts "ActiveRecord - Native Database Types Override #{NativeDbTypesOverride::VERSION}" if NativeDbTypesOverride.debug?
      hash.keys.each do |clazz|
        new_types = {}
        begin
          new_types = clazz.const_get('NATIVE_DATABASE_TYPES')
        rescue
          puts "No NATIVE_DATABASE_TYPES constant on #{clazz} so expecting the whole types hash to be specified in the NativeDbTypesOverride::Options.configure" if NativeDbTypesOverride.debug?
        end
        new_types = new_types.merge(hash[clazz])
        puts "Defining #{clazz}.native_database_types as #{new_types.inspect}" if NativeDbTypesOverride.debug?
        clazz.class_eval "def native_database_types; #{new_types.inspect}; end"
      end
    end
  end
end
