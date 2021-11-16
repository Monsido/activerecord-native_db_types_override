module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements
      alias_method :add_reference_without_native_db_types_override, :add_reference

      def add_reference(table_name, ref_name, **options)
        if ::NativeDbTypesOverride.migrations_options
          add_ref_opts = ::NativeDbTypesOverride.migrations_options[:add_reference]
          options = Marshal.load(Marshal.dump(add_ref_opts)).merge(options) if add_ref_opts
        end

        add_reference_without_native_db_types_override(table_name, ref_name, **options)
      end
    end
  end
end
