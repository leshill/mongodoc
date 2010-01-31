module MongoDoc
  module Associations
    class ProxyBase
      undef_method :id, :to_bson

      attr_reader :assoc_name, :assoc_class, :_parent, :_root

      def _parent=(parent)
        @_parent = parent
      end

      def _path_to_root(src, attrs)
        _parent._path_to_root(src, annotated_keys(src, attrs))
      end

      def _root=(root)
        @_root = root
      end

      def initialize(options)
        @assoc_name = options[:assoc_name]
        @assoc_class = options[:assoc_class]
        @_root = options[:root]
        @_parent = options[:parent]
      end

      def attach(item)
        if is_document?(item)
          item._parent = self
          item._root = _root
          _root.send(:register_save_observer, item)
        end
        item
      end

      protected

      def annotated_keys(src, hash)
        annotated = {}
        hash.each do |(key, value)|
          annotated["#{assoc_name}.#{key}"] = value
        end
        annotated
      end

      def is_document?(object)
        object.respond_to?(:_parent)
      end
    end
  end
end
