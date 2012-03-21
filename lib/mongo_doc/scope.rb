# Based on ActiveRecord::NamedScope
module MongoDoc
  module Scope
    def self.extended(klass)
      klass.class_attribute :_scopes
    end

    def scopes
      self._scopes ||= {}
    end

    def scope(name, *args, &block)
      options = args.extract_options!
      raise ArgumentError if args.size != 1
      criteria = args.first
      name = name.to_sym
      scopes[name] = lambda do |parent_scope, *args|
        CriteriaProxy.new(parent_scope, Mongoid::Criteria === criteria ? criteria : criteria.call(*args), options, &block)
      end
      (class << self; self; end).class_eval <<-EOT
        def #{name}(*args)
          scopes[:#{name}].call(self, *args)
        end
      EOT
    end

    class CriteriaProxy
      if RUBY_VERSION.starts_with?('1.8')
        undef id
      end

      attr_accessor :criteria, :klass, :parent_scope

      delegate :scopes, :to => :parent_scope

      def initialize(parent_scope, criteria, options, &block)
        [options.delete(:extend)].flatten.each { |extension| extend extension } if options.include?(:extend)
        extend Module.new(&block) if block_given?
        if CriteriaProxy === parent_scope
          chained = Mongoid::Criteria.new(klass)
          chained.merge(parent_scope)
          chained.merge(criteria)
          self.criteria = chained
          self.klass = criteria.klass
        else
          self.criteria = criteria
          self.klass = parent_scope
        end

        self.parent_scope = parent_scope
      end

      def respond_to?(method, include_private = false)
        return true if scopes.include?(method)
        criteria.respond_to?(method, include_private)
      end

      private

      def method_missing(method, *args, &block)
        if scopes.include?(method)
          scopes[method].call(self, *args)
        else
          chained = Mongoid::Criteria.new(klass)
          chained.merge(criteria)
          chained.send(method, *args, &block)
        end
      end
    end
  end
end

