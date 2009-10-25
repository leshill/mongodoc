# Thanks Sandro!
# http://github.com/sandro
module MongoDoc
  module Document
    class Proxy
      # List of array methods (that are not in +Object+) that need to be
      # delegated to +collection+.
      ARRAY_METHODS = (Array.instance_methods - Object.instance_methods).map { |n| n.to_s }

      # List of additional methods that must be delegated to +collection+.
      MUST_DEFINE = %w[to_a to_ary inspect]

      (ARRAY_METHODS + MUST_DEFINE).uniq.each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}(*args, &block)                 # def each(*args, &block)
            collection.send(:#{method}, *args, &block)  #   collection.send(:each, *args, &block)
          end                                          # end
        RUBY
      end

      attr_reader :collection, :collection_class, :_parent, :_root

      def _parent=(parent)
        @_parent = parent
      end

      def _root=(root)
        @_root = root
        collection.each do |item|
          item._root = root
        end
      end

      def initialize(options)
        @collection = []
        @collection_class = options[:collection_class]
        @_root = options[:root]
        @_parent = options[:parent]
      end

      alias_method :append, :<<
      def <<(items)
        [*items].each do |item|
          item = collection_class.new(item) if Hash === item
          raise NotADocumentError unless collection_class === item
          append item
          item._parent = self
          item._root = _root
        end
        self
      end
      alias_method :push, :<<
      alias_method :concat, :<<

      # Lie about our class. Borrowed from Rake::FileList
      # Note: Does not work for case equality (<tt>===</tt>)
      def is_a?(klass)
        klass == Array || super(klass)
      end
      alias kind_of? is_a?

    end
  end
end