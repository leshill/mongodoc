# Thanks Sandro!
# http://github.com/sandro
module MongoDoc
  module Associations
    class CollectionProxy
      include ProxyBase

      # List of array methods (that are not in +Object+) that need to be
      # delegated to +collection+.
      ARRAY_METHODS = (Array.instance_methods - Object.instance_methods).map { |n| n.to_s }

      # List of additional methods that must be delegated to +collection+.
      MUST_DEFINE = %w[to_a to_ary inspect to_bson ==]

      DO_NOT_DEFINE = %w[concat insert replace]

      (ARRAY_METHODS + MUST_DEFINE - DO_NOT_DEFINE).uniq.each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}(*args, &block)                 # def each(*args, &block)
            collection.send(:#{method}, *args, &block) #   collection.send(:each, *args, &block)
          end                                          # end
        RUBY
      end

      attr_reader :collection

      def _modifier_path=(path)
        super
        collection.each do |item|
          item._modifier_path = _modifier_path + '.$' if ProxyBase.is_document?(item)
        end
      end

      def _root=(value)
        @_root = value
        collection.each do |item|
          item._root = value if ProxyBase.is_document?(item)
        end
      end

      %w(_root _selector_path).each do |setter|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{setter}=(val)
            super
            collection.each do |item|
              item.#{setter} = #{setter} if ProxyBase.is_document?(item)
            end
          end
        RUBY
      end

      def initialize(options)
        @collection = []
        super
      end

      alias _append <<
      def <<(item)
        attach(item)
        _append item
        self
      end
      alias push <<

      alias add []=
      def []=(index, item)
        attach(item)
        add(index, item)
      end
      alias insert []=

      def build(attrs)
        item = _assoc_class.new(attrs)
        push(item)
      end

      def concat(array)
        array.each do |item|
          push(item)
        end
      end

      # Lie about our class. Borrowed from Rake::FileList
      # Note: Does not work for case equality (<tt>===</tt>)
      def is_a?(klass)
        klass == Array || super(klass)
      end
      alias kind_of? is_a?

      def replace(other)
        clear
        concat(other)
      end

      alias _unshift unshift
      def unshift(item)
        attach(item)
        _unshift(item)
      end

      def valid?
        all? do |child|
          if ProxyBase.is_document?(child)
            child.valid?
          else
            true
          end
        end
      end

      protected

      def attach_document(doc)
        doc._modifier_path = _modifier_path + '.$'
        doc._selector_path = _selector_path
        doc._root = _root
        _root.send(:register_save_observer, doc)
      end
    end
  end
end
