# coding: utf-8
require "active_support/concern"

module ConstEnum
  module WithI18n
    extend ActiveSupport::Concern

    DEFAULT_OPTIONS = { :key => 'labels'}
    
    included do
      self.i18n_options = DEFAULT_OPTIONS.dup
    end
    
    def label
      I18n.t(build_key(@attributes.second || key.to_s.downcase))
    end
    
    private
    def build_key(key)
      "#{self.class.i18n_options[:key]}.#{key}"
    end
  
    module ClassMethods
      def i18n_options
        @i18n_options
      end
      
      def i18n_options=(options)
        @i18n_options = options
      end
    end
    
  end
end