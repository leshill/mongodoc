require 'mongodoc/proxy'
require 'mongodoc/parent_proxy'

module MongoDoc
  module Attributes
    def self.extended(klass)
      klass.class_inheritable_array :_keys
      klass._keys = []
      klass.class_inheritable_array :_associations
      klass._associations = []

      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        attr_accessor :_parent

        def _root
          @_root
        end

        def _root=(root)
          @_root = root
          _associations.each do|a|
            association = send(a)
            association._root = root if association
          end
        end

        def path_to_root(prev)
          return prev unless _parent
          _parent.path_to_root(prev)
        end
      RUBY
    end

    def _attributes
      _keys + _associations
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
          if value
            raise NotADocumentError unless Document === value
            value._parent = ParentProxy.new(self, name)
            value._root = _root || self
            value._root.register_save_observer(value)
          end
          instance_variable_set("@#{name}", value)
        end

        validates_associated name
      end
    end

    def has_many(*args)
      options = args.extract_options!
      collection_class = if class_name = options.delete(:class_name)
        type_name_with_module(class_name).constantize
      end

      args.each do |name|
        _associations << name unless _associations.include?(name)

        define_method("#{name}") do
          association = instance_variable_get("@#{name}")
          unless association
            association = Proxy.new(:root => _root || self, :parent => self, :assoc_name => name, :collection_class => collection_class || self.class.type_name_with_module(name.to_s.classify).constantize)
            instance_variable_set("@#{name}", association)
          end
          association
        end

        validates_associated name

        define_method("#{name}=") do |arrayish|
          proxy = send("#{name}")
          proxy.clear
          Array.wrap(arrayish).each do|item|
            proxy << item
          end
        end
      end
    end

    def type_name_with_module(type_name)
      (/^::/ =~ type_name) ? type_name : "#{parents}::#{type_name}"
    end
  end
end
