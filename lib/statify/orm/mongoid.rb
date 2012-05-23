module Statify
  module Orm
    module Mongoid
      def _collection_scope_helper
        scope sym, where(:status => sym)
      end
      def _configure_collection_accessors(name, options)
        field_options = {}
        field_options[:default] = options[:default] if options.key? :default
        type = (options[:symbolize_keys]) ? Symbol : String
        field name, :type => type, field_options
      end
    end
  end
end