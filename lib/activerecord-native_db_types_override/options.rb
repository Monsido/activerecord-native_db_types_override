module NativeDbTypesOverride
  class << self
    attr_accessor :debug, :adapters_options, :migrations_options

    def debug?
      !!send(:debug)
    end

    def configure(hash)
      warn 'NativeDbTypesOverride.configure is deprecated! Call NativeDbTypesOverride.configure_adapters instead of NativeDbTypesOverride.configure.'
      configure_adapters(hash)
    end

    def configure_adapters(hash)
      puts "ActiveRecord - Native Database Types Override #{NativeDbTypesOverride::VERSION} - configure_adapters called" if NativeDbTypesOverride.debug?
      hash.keys.each do |key|
        begin
          clazz = ::NativeDbTypesOverride::AdapterOverrider.convert_symbol_to_class(key)
        rescue => e
          raise ::NativeDbTypesOverride::ConfigurationError.new "Unable to get adapter class for #{key.inspect}. Try specifying the adapter class itself as the key in the hash in NativeDbTypesOverride.configure(). Error: #{e.message}\n#{e.backtrace.join("\n")}"
        end

        ::NativeDbTypesOverride::AdapterOverrider.override_native_database_types(clazz, hash[key])
      end
    end

    def configure_migrations(hash)
      puts "ActiveRecord - Native Database Types Override #{NativeDbTypesOverride::VERSION} - configure_adapters called" if NativeDbTypesOverride.debug?
      self.migrations_options = hash
    end
  end
end
