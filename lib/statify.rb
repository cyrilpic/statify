require "statify/version"

require "active_support/concern"
require "statify/orm/default"
require "statify/orm/mongoid"

module Statify
  
  module Models
    extend ActiveSupport::Concern
    
    included do
      if Rails::Application::const_defined?(:Mongoid) && include?(Mongoid::Document)
        extend Statify::Orm::Mongoid
      else
        extend Statify::Orm::Default
      end
    end
    
    module ClassMethods
      def register_collection(name, list, options = {})
        options = {symbolize_keys: true}.merge options
        @_collections_code ||= {}
        name = name.to_sym
        # Setup the model if it's the first time it's called for this name
        if @_collections_code[name].nil?
          _configure_collection name, options
          @_collections_code[name] = []
        end
        # Add list to the collection
        array_list = _sanitize_collection_list list, options
        @_collections_code[name] += array_list
        
        array_list.each do |sym|
          method_name = (name == :status) ? "#{sym.to_s}?" : "#{name}_#{sym.to_s}?"
          define_method method_name do
            self.__send__(name) == sym
          end
          
          _collection_scope_helper(name, sym)
        end
      end
    
      def possible_collection(name)
        @_collections_code[name.to_sym]
      end
    
      # Compatibility methods
      def register_status(list, options = {})
        register_collection :status, list, options
      end
      def possible_status
        possible_collection(:status)
      end
      
      private
      def _sanitize_collection_list(list, options)
        sanitized_list = (list.is_a? Array ) ? list : [list]
        sanitized_list.map(&:to_sym) if options[:symbolize_keys]
      end
    
      def _configure_collection(name, options)
        validates name, :presence => true, :inclusion => { :in => lambda { |record| @_collections_code[name] } }
        
        define_method("set_next_#{name.to_s}") do
          _collections_code = self.class.instance_variable_get('@_collections_code');
          next_i = _collections_code[name].index(self.__send__(name)) + 1
          self.__send__ "#{name.to_s}=", _collections_code[name][next_i] if _collections_code[name].count > next_i
        end
        
        define_method("set_previous_#{name.to_s}") do
          _collections_code = self.class.instance_variable_get('@_collections_code');
          prev_i = _collections_code[name].index(self.__send__(name)) - 1
          self.__send__ "#{name.to_s}=", _collections_code[name][prev_i] unless prev_i < 0
        end
        
        _configure_collection_accessors(name, options)
      end
    
    end
  end
end

if Rails::Application::const_defined? :ActiveRecord
  ActiveRecord::Base.__send__ :include, Statify::Models
end
if Rails::Application::const_defined? :Mongoid
  Mongoid::Document::ClassMethods.class_eval do
    include Statify::Models
  end
end