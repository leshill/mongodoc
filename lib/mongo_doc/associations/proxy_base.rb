module MongoDoc
  module Associations
    module ProxyBase
      def self.included(klass)
        klass.class_eval do
          attr_reader :assoc_name, :assoc_class, :_parent, :_root
        end
      end

      def _parent=(parent)
        @_parent = parent
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

      def _path_to_root
        path = _parent._path_to_root
        path.empty? ? assoc_name.to_s : path + '.' + assoc_name.to_s
      end

      def _update_path_to_root
        path = _parent._update_path_to_root
        path.empty? ? assoc_name.to_s : path + '.' + assoc_name.to_s
      end

      protected

      def attach(item)
        if is_document?(item)
          item._parent = self
          item._root = _root
          _root.send(:register_save_observer, item)
        end
        item
      end

      def is_document?(object)
        object.respond_to?(:_parent)
      end
    end
  end
end
