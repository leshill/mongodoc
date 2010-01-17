# Thanks Sandro!
# http://github.com/sandro
module MongoDoc
  class Proxy
    # List of array methods (that are not in +Object+) that need to be
    # delegated to +collection+.
    ARRAY_METHODS = (Array.instance_methods - Object.instance_methods).map { |n| n.to_s }

    # List of additional methods that must be delegated to +collection+.
    MUST_DEFINE = %w[to_a to_ary inspect to_bson ==]

    (ARRAY_METHODS + MUST_DEFINE).uniq.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(*args, &block)                 # def each(*args, &block)
          collection.send(:#{method}, *args, &block)  #   collection.send(:each, *args, &block)
        end                                          # end
      RUBY
    end

    attr_reader :assoc_name, :collection, :collection_class, :_parent, :_root

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
      @assoc_name = options[:assoc_name]
      @collection = []
      @collection_class = options[:collection_class]
      @_root = options[:root]
      @_parent = options[:parent]
    end

    alias_method :append, :<<
    def <<(item)
      item = build(item) if Hash === item
      if Document === item
        item._parent = self
        item._root = _root
        _root.send(:register_save_observer, item)
      end
      append item
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

    def _path_to_root(src, attrs)
      assoc_path = "#{assoc_name}.#{index(src)}"
      assoc_attrs = attrs.inject({}) do |assoc_attrs, (key, value)|
        assoc_attrs["#{assoc_path}.#{key}"] = value
        assoc_attrs
      end
      _parent._path_to_root(src, assoc_attrs)
    end

    def build(attrs)
      collection_class.new(attrs)
    end
  end
end
