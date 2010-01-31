module MongoDoc
  module Associations
    class HashProxy < ProxyBase
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

      attr_reader :hash

      def _root=(root)
        @_root = root
        hash.each do |key, value|
          value._root = root if is_document?(value)
        end
      end

      def initialize(options)
        super
        @hash = {}
      end

      alias put []=
      def []=(key, value)
        raise InvalidEmbeddedHashKey.new("Key name [#{key}] must be a valid element name, see http://www.mongodb.org/display/DOCS/BSON#BSON-noteonelementname") unless valid_key?(key)
        attach(value)
        put(key, value)
      end
      alias store []=

      def build(key, attrs)
        item = assoc_class.new(attrs)
        store(key, item)
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
      alias update merge!

      def replace(other)
        clear
        merge!(other)
      end

      def valid?
        values.all? do |child|
          if is_document?(child)
            child.valid?
          else
            true
          end
        end
      end

      protected

      def annotated_keys(src, attrs)
        assoc_path = "#{assoc_name}.#{index(src)}"
        annotated = {}
        attrs.each do |(key, value)|
          annotated["#{assoc_path}.#{key}"] = value
        end
        annotated
      end

      def valid_key?(key)
        (String === key or Symbol === key) and key.to_s !~ /(_id|query|\$.*|.*\..*)/
      end
    end
  end
end
