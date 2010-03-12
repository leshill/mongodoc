require 'mongo_doc/associations/proxy_base'
require 'mongo_doc/associations/collection_proxy'
require 'mongo_doc/associations/document_proxy'
require 'mongo_doc/associations/hash_proxy'

module MongoDoc
  module Associations

    def has_one(*args)
      options = args.extract_options!
      assoc_class = if class_name = options.delete(:class_name)
        self.class_from_name(class_name)
      end

      args.each do |name|
        _associations << name unless _associations.include?(name)

        attr_reader name

        define_method("#{name}=") do |value|
          association = instance_variable_get("@#{name}")
          unless association
            association = Associations::DocumentProxy.new(:root => _root || self, :parent => self, :assoc_name => name, :assoc_class => assoc_class || self.class.class_from_name(name))
            instance_variable_set("@#{name}", association)
          end
          association.document = value
        end

        validates_embedded name, :if => Proc.new { !send(name).nil? }
      end
    end

    def has_many(*args)
      options = args.extract_options!
      assoc_class = if class_name = options.delete(:class_name)
        self.class_from_name(class_name)
      end

      args.each do |name|
        _associations << name unless _associations.include?(name)

        define_method("#{name}") do
          association = instance_variable_get("@#{name}")
          unless association
            association = Associations::CollectionProxy.new(:root => _root || self, :parent => self, :assoc_name => name, :assoc_class => assoc_class || self.class.class_from_name(name))
            instance_variable_set("@#{name}", association)
          end
          association
        end

        validates_embedded name

        define_method("#{name}=") do |arrayish|
          proxy = send("#{name}")
          proxy.clear
          Array.wrap(arrayish).each do|item|
            proxy << item
          end
        end
      end
    end

    def has_hash(*args)
      options = args.extract_options!
      assoc_class = if class_name = options.delete(:class_name)
        self.class_from_name(class_name)
      end

      args.each do |name|
        _associations << name unless _associations.include?(name)

        define_method("#{name}") do
          association = instance_variable_get("@#{name}")
          unless association
            association = Associations::HashProxy.new(:root => _root || self, :parent => self, :assoc_name => name, :assoc_class => assoc_class || self.class.class_from_name(name))
            instance_variable_set("@#{name}", association)
          end
          association
        end

        validates_embedded name

        define_method("#{name}=") do |hash|
          send("#{name}").replace(hash)
        end
      end
    end

    def class_from_name(name)
      type_name_with_module(name.to_s.classify).constantize rescue nil
    end

    def type_name_with_module(type_name)
      (/^::/ =~ type_name) ? type_name : "#{parent}::#{type_name}"
    end
  end
end
