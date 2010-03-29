module MongoDoc
  module Associations
    module ProxyBase
      def self.included(klass)
        klass.class_eval do
          attr_reader :_assoc_class, :_assoc_name, :_modifier_path, :_root, :_selector_path
        end
      end

      %w(_modifier_path _selector_path).each do |setter|
        module_eval(<<-RUBY, __FILE__, __LINE__)
          def #{setter}=(path)
            @#{setter} = (path.blank? ? '' : path + '.') + _assoc_name.to_s
          end
        RUBY
      end

      def _root=(root)
        @_root = root
      end

      def initialize(options)
        @_assoc_name = options[:assoc_name]
        @_assoc_class = options[:assoc_class]
        self._root = options[:root]
        self._selector_path = self._modifier_path = options[:path]
      end

      def self.is_document?(object)
        object.respond_to?(:_root)
      end

      protected

      def attach(obj)
        attach_document(obj) if ProxyBase.is_document?(obj)
        obj
      end

      def attach_document(doc)
        doc._modifier_path = _modifier_path
        doc._selector_path = _selector_path
        doc._root = _root
        _root.send(:register_save_observer, doc)
      end
    end
  end
end
