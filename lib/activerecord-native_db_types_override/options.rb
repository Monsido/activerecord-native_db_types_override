module NativeDbTypesOverride
  class Options
    def self.configure(hash)
      puts "ActiveRecord - Native Database Types Override #{NativeDbTypesOverride::VERSION}"

      hash.keys.each do |clazz|
        # do the override
        new_types = {}

        begin
          new_types = clazz.const_get('NATIVE_DATABASE_TYPES')
        rescue
          puts "No NATIVE_DATABASE_TYPES constant on #{clazz} so expecting the whole types hash to be specified in the NativeDbTypesOverride::Options.configure"
        end

        new_types = new_types.merge(hash[clazz])

        puts "Setting #{clazz}.native_database_types to #{new_types.inspect}"

        clazz.class_eval "def native_database_types; #{new_types.inspect}; end"

        puts "ActiveRecord - Native Database Types Override success"
      end
    end
  end
end
