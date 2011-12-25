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
        if Rails::Application::const_defined?(:Mongoid) && include?(Mongoid::Document)
          scope sym, where(:status => sym)
        else
          scope sym, where(:status => @_status_code.index(sym))
        end
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
      
      if Rails::Application::const_defined?(:Mongoid) && include?(Mongoid::Document)
        field :status, :type => Symbol, :default => sym
      else
        after_initialize lambda { self.status = sym if self[:status].nil? }
        define_method('status') do
          _status_code = self.class.instance_variable_get('@_status_code');
          (self[:status].nil? ? sym : _status_code[self[:status]])
        end
        define_method('status=') do |value|
          _status_code = self.class.instance_variable_get('@_status_code');
          self[:status] = _status_code.index(value.to_sym)
        end
      end
    end
    
    def possible_status
      @_status_code
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