module MongoDoc
  module Document
    module Attributes
      module Tree
        attr_accessor :_parent

        def _root
          @_root
        end

        protected :_parent=

        protected

        def _root=(root)
          _associations.each do|a|
            association = send(a)
            association._root = root if association
          end
          @_root = root
        end
      end

      def self.extended(klass)
        klass.class_inheritable_array :_keys
        klass._keys = []
        klass.class_inheritable_array :_associations
        klass._associations = []

        klass.class_eval <<-EOS
          include Tree

          def self._attributes
            _keys + _associations
          end
        EOS
      end

      def key(*args)
        args.each do |name|
          _keys << name unless _keys.include?(name)
          attr_accessor name
        end
      end

      def has_one(*args)
        args.each do |name|
          _associations << name unless _associations.include?(name)
          attr_reader name
          define_method("#{name}=") do |value|
            raise MongoDoc::Document::NotADocument unless Document === value
            value._parent = self
            value._root = _root || self
            instance_variable_set("@#{name}", value)
          end
        end
      end
    end
  end
end
