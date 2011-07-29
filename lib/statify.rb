require "statify/version"

require "active_support/concern"

module Statify
  
  module Models
    extend ActiveSupport::Concern

    def register_status(syms,hash = {})
      @_status_code ||= []
      array  = (syms.is_a?(Array) ? syms : [syms])
      default = hash[:default] || array.first
      configure_status(default) unless @_status_code.any?
      @_status_code += array
      array.each do |sym|
        define_method (sym.to_s+"?") do
          self.status == sym
        end
        scope sym, where(:status => sym)
      end
    end
  
    def configure_status(sym)
      validates :status, :presence => true, :inclusion => { :in => lambda { |record| @_status_code } }
      
      define_method('set_next_status') do
        _status_code = self.class.instance_variable_get('@_status_code');
        next_status_i = _status_code.index(self.status) + 1
        self.status = _status_code[next_status_i] if _status_code.count > next_status_i
      end
      define_method('set_previous_status') do
        _status_code = self.class.instance_variable_get('@_status_code');
        prev_status_i = _status_code.index(self.status) - 1
        self.status = _status_code[prev_status_i] unless prev_status_i < 0
      end
      
      if include? Mongoid::Document
        field :status, :type => Symbol, :default => sym
      else
        define_method('status') do
          @_status_code[self.read_attribute('status')]
        end
        define_method('status=') do |value|
          self.write_attribute('status',@_status_code.index(value))
        end
      end
    end
  end
  
end

if Rails::Application::const_defined? :ActiveRecord
  ActiveRecord::Base.extend Statify::Models
end
if Rails::Application::const_defined? :Mongoid
  Mongoid::Document::ClassMethods.class_eval do
    include Statify::Models
  end
end