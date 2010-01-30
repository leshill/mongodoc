module MongoDoc
  module Associations
    class ParentProxy
      attr_reader :assoc_name, :_parent

      def initialize(parent, assoc_name)
        raise ArgumentError.new('ParentProxy requires a parent') if parent.nil?
        raise ArgumentError.new('ParentProxy require an association name') if assoc_name.blank?
        @_parent = parent
        @assoc_name = assoc_name
      end

      def _path_to_root(src, attrs)
        _parent._path_to_root(src, _annotated_keys(attrs))
      end

      protected

      def _annotated_keys(hash)
        annotated = {}
        hash.each do |(key, value)|
          annotated["#{assoc_name}.#{key}"] = value
        end
        annotated
      end

      private

      def method_missing(method, *args)
        unless @_parent.respond_to?(method)
          message = "undefined method `#{method.to_s}' for proxied \"#{@_parent}\":#{@_parent.class.to_s}"
          raise NoMethodError, message
        end

        if block_given?
          @_parent.send(method, *args)  { |*block_args| yield(*block_args) }
        else
          @_parent.send(method, *args)
        end
      end
    end
  end
end
