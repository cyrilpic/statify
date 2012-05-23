module Statify
  module Orm
    module Mongoid
      def _collection_scope_helper(name, sym)
        scope sym, where(name => sym)
      end
      def _configure_collection_accessors(name, options)
        type = (options[:symbolize_keys]) ? Symbol : String
        field_options = {
          type: type
        }
        field_options[:default] = options[:default] if options.key? :default
        field name field_options
      end
    end
  end
end