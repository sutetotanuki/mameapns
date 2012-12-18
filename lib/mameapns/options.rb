module Mameapns
  module Options
    def self.included(base)
      base.extend(ClassMethods)
    end

    def initialize(values={})
      # like a sybolize_keys in active support
      values.keys.each { |k| values[k.to_sym] = values.delete(k) }
      
      self.class.attrs.each do |attr_name, option|
        if values.keys.include?(attr_name)
          self.__send__("#{attr_name}=", values[attr_name]) 
        else
          if option[:default]
            self.__send__("#{attr_name}=", option[:default])
          end
        end
      end
    end

    def to_hash
      hash = {}
      self.class.attrs.each do |attr_name, option|
        value = self.send(attr_name)
        if value.respond_to?(:to_hash)
          hash[attr_name.to_s] = value.to_hash
        else
          hash[attr_name.to_s] = value
        end
      end
      
      hash
    end

    def to_json
      to_hash.to_json
    end
    
    alias :initialize_options :initialize

    module ClassMethods
      def attrs
        @attrs ||= {}
      end
      
      def options(name, option={})
        class_eval do
          attr_accessor name
        end

        attrs[name] = option
      end
    end
  end
end
