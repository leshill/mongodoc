require 'mongodoc/bson'
require 'mongodoc/value_equals'
require 'mongodoc/query'
require 'mongodoc/attributes'

module MongoDoc
  class DocumentInvalidError < RuntimeError; end
  class NotADocumentError < RuntimeError; end

  module DocumentValueEquals
    def ==(other)
      return false unless self.class === other
      self.class._attributes.all? {|var| self.send(var) == other.send(var)}
    end
  end
  
  module Identity
    attr_accessor :_id
    alias :id :_id
    alias :to_param :_id

    def new_record?
      _id.nil?
    end
  end
  
  module ToBSON
    def to_bson(*args)
      {MongoDoc::BSON::CLASS_KEY => self.class.name}.tap do |bson_hash|
        bson_hash['_id'] = _id unless _id.nil?
        self.class._attributes.each do |name|
          bson_hash[name.to_s] = send(name).to_bson(args)
        end
      end
    end
  end
  
  module BSONCreate
    def bson_create(bson_hash, options = {})
      new.tap do |obj|
        bson_hash.each do |name, value|
          obj.send("#{name}=", MongoDoc::BSON.decode(value, options))
        end
      end
    end
  end

  class Document
    extend MongoDoc::Attributes
    extend MongoDoc::BSONCreate
    include MongoDoc::ToBSON
    include MongoDoc::DocumentValueEquals
    include MongoDoc::Identity
    include Validatable

    def attributes=(attrs)
      attrs.each do |key, value|
        send("#{key}=", value)
      end
    end

    def initialize(attrs = {})
      self.attributes = attrs
    end

    def save(validate = true)
      return _root.save(validate) if _root
      return _save(false) unless validate and not valid?
      false
    end
    
    def save!
      return _root.save! if _root
      raise DocumentInvalidError unless valid?
      _save(true)
    end

    def update_attributes(attrs)
      self.attributes = attrs
      return _propose_update_attributes(self, path_to_root(attrs), false) if valid?
      false
    end

    def update_attributes!(attrs)
      self.attributes = attrs
      raise DocumentInvalidError unless valid?
      _propose_update_attributes(self, path_to_root(attrs), true)
    end

    class << self
      def collection_name
        self.to_s.tableize.gsub('/', '.')
      end

      def collection
        @collection ||= MongoDoc::Collection.new(collection_name)
      end

      def count
        collection.count
      end

      def create(attrs = {})
        instance = new(attrs)
        _create(instance, false) if instance.valid?
        instance
      end
    
      def create!(attrs = {})
        instance = new(attrs)
        raise MongoDoc::DocumentInvalidError unless instance.valid?
        _create(instance, true)
        instance
      end

      def find_one(id)
        MongoDoc::BSON.decode(collection.find_one(id))
      end

      protected
      
      def _create(instance, safe)
        instance._id = collection.insert(instance, :safe => safe)
      end
    end

    protected

    def _collection
      self.class.collection
    end
    
    def _propose_update_attributes(src, attrs, safe)
      return _parent.send(:_propose_update_attributes, src, attrs, safe) if _parent
      _update_attributes(attrs, safe)
    end

    def _save(safe)
      self._id = _collection.save(self, :safe => safe)
    end

    def _update_attributes(attrs,  safe)
      _collection.update({'_id' => self._id}, MongoDoc::Query.set_modifier(attrs), :safe => safe)
    end
  end
end
