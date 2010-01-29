module MongoDoc
  class HashProxy
    HASH_METHODS = (Hash.instance_methods - Object.instance_methods).map { |n| n.to_s }

    MUST_DEFINE = %w[to_a inspect to_bson ==]

    DO_NOT_DEFINE = %w[merge! replace store update]

    (HASH_METHODS + MUST_DEFINE - DO_NOT_DEFINE).uniq.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(*args, &block)            # def each(*args, &block)
          hash.send(:#{method}, *args, &block)  #   hash.send(:each, *args, &block)
        end                                     # end
      RUBY
    end

    attr_reader :assoc_name, :hash, :assoc_class, :_parent, :_root

    def _parent=(parent)
      @_parent = parent
    end

    def _path_to_root(src, attrs)
      assoc_path = "#{assoc_name}.#{index(src)}"
      assoc_attrs = {}
      attrs.each do |(key, value)|
        assoc_attrs["#{assoc_path}.#{key}"] = value
      end
      _parent._path_to_root(src, assoc_attrs)
    end

    def _root=(root)
      @_root = root
      hash.each do |key, value|
        value._root = root if is_document?(value)
      end
    end

    def initialize(options)
      @assoc_name = options[:assoc_name]
      @hash = {}
      @assoc_class = options[:assoc_class]
      @_root = options[:root]
      @_parent = options[:parent]
    end

    alias_method :add, :[]=
    def []=(key, value)
      raise InvalidEmbeddedHashKey.new("Key name [#{key}] must be a valid element name, see http://www.mongodb.org/display/DOCS/BSON#BSON-noteonelementname") unless valid_key?(key)
      if is_document?(value)
        value._parent = self
        value._root = _root
        _root.send(:register_save_observer, value)
      end
      add(key, value)
    end
    alias_method :store, :[]=

    def build(attrs)
      assoc_class.new(attrs)
    end

    # Lie about our class. Borrowed from Rake::FileList
    # Note: Does not work for case equality (<tt>===</tt>)
    def is_a?(klass)
      klass == Hash || super(klass)
    end
    alias kind_of? is_a?

    def merge!(other)
      other.each_pair do |key, value|
        self[key] = if block_given?
          yield key, [key], value
        else
          value
        end
      end
    end
    alias_method :update, :merge!

    def replace(other)
      clear
      merge!(other)
    end

    def validate_children
      unless values.all? {|child| child.valid? }
        _parent.errors.add(assoc_name, "is invalid")
      end
    end

    protected

    def valid_key?(key)
      (String === key or Symbol === key) and key.to_s !~ /(_id|query|\$.*|.*\..*)/
    end

    def is_document?(object)
      object.respond_to?(:_parent)
    end
  end
end
