# coding: utf-8
require "active_support/core_ext/module"
require "active_support/core_ext/array"

module ConstEnum
  class Base
    attr_reader :attributes, :key
    delegate :from, :to, :first, :second, :third, :fourth, :fifth, :last, :forty_two, :to => :attributes
    
    def initialize(key, *attributes)
      @key = key
      @attributes = attributes
      @attributes.freeze
    end
    
    def [](pos)
      @attributes[pos]
    end
    
    def value
      @attributes.first
    end
    
    def label
      @attributes.second
    end
    
    def inspect
      "#{@attributes.first.inspect}:#{(@attributes[2 .. -1]||[]).unshift(label).map(&:inspect).join(', ')}"
    end
    
    def to_s
      "#{@attributes.first.inspect}:#{(@attributes[2 .. -1]||[]).unshift(label).map(&:inspect).join(', ')}"
    end
    
    class << self
      include Enumerable
      def inherited(clazz)
        hash_class = RUBY_VERSION < '1.9' ? ActiveSupport::OrderedHash : Hash 
        clazz.instance_variable_set(:@instances, hash_class.new)
        clazz.instance_variable_set(:@keys, hash_class.new)
      end
      
      def include?(value)
        (ConstEnum === value) ? @instances.include?(value) : @instances.key?(value)
      end
      
      def [](value)
        @instances[value]
      end
      
      def label(value)
        @instances[value].label
      end
      
      def key(value)
        @keys[value]
      end
      
      def keys
        @keys.values
      end
      
      def values
        @instances.keys
      end
      
      def labels
        @instances.values.map(&:label)
      end
      
      def size
        @instances.size
      end
      
      def each
        return Enumerator.new(self) unless block_given?
        @instances.each {|value, obj| yield obj }
      end
      
      def each_key
        return Enumerator.new(self, :each_key) unless block_given?
        keys.each {|key| yield key }
      end
      
      def each_value
        return Enumerator.new(self, :each_value) unless block_given?
        values.each {|value| yield value }
      end
      
      def each_label
        return Enumerator.new(self, :each_label) unless block_given?
        labels.each {|label| yield label }
      end
      
      def inspect
        to_s
      end

      def to_s
        return super if ConstEnum::Base == self
        elems = []
        @keys.each do |value, key|
          elems << "#{key}[#{@instances[value]}]"
        end
        super << " { #{elems.join(', ')} }"
      end

      protected
      def define_const(key, value, *args)
        raise "already initialized constant value #{value}. name: #{key} defined_name: #{@keys[value]}"if @instances.key? value
        const_set(key, value)
        obj = self.new(key, value, *args)
        singleton_class.__send__(:define_method, key) { obj }
        obj.freeze
        @instances[value] = obj
        @keys[value] = key
      end
    end
  end
end