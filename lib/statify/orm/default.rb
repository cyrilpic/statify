module Statify
  module Orm
    module Default
      def _collection_scope_helper(name, sym)
        scope sym, -> { where(name => @_collections_code[name].index(sym)) }
      end
      def _configure_collection_accessors(name, options)
        default_value = options[:default]
        if options.key? :default
          after_initialize lambda { 
            begin
              self.__send__("#{name}=", default_value) if self.__send__(name).nil?
            rescue ActiveModel::MissingAttributeError => e
            end
          }
        end
        
        define_method(name) do
          _collections_code = self.class.instance_variable_get('@_collections_code');
          (self[name].nil? ? default_value : _collections_code[name][self[name]])
        end
        define_method("#{name}=") do |value|
          _collections_code = self.class.instance_variable_get('@_collections_code');
          sanitized_value = (options[:symbolize_keys]) ? value.to_sym : value
          self[name] = _collections_code[name].index(sanitized_value)
        end
      end
    end
  end
end
