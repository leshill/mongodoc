require 'mongodoc/bson'
require 'mongodoc/value_equals'
require 'mongodoc/query'
require 'mongodoc/attributes'

module MongoDoc
  module Document
    class DocumentInvalidError < RuntimeError; end
    class NotADocumentError < RuntimeError; end

    def self.included(klass)
      klass.instance_eval do
        extend MongoDoc::Document::Attributes
        extend MongoDoc::Document::BSONCreate
        include MongoDoc::Document::ToBSON
        include MongoDoc::Document::ValueEquals
        include MongoDoc::Document::Identity
        include Validatable
      end
    end

    module ValueEquals
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
  end

  class Base
    include MongoDoc::Document

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
      unless validate and not valid?
        _save(false)
      else
        false
      end
    end
    
    def save!
      return _root.save! if _root
      if valid?
        _save(true)
      else
        raise DocumentInvalidError
      end
    end

    def update_attributes(attrs)
      self.attributes = attrs
      return false unless valid?
      _propose_update_attributes(self, path_to_root(attrs), false)
    end

    def update_attributes!(attrs)
      self.attributes = attrs
      if valid?
        _propose_update_attributes(self, path_to_root(attrs), true)
      else
        raise DocumentInvalidError
      end
    end

    def self.collection_name
      self.to_s.tableize.gsub('/', '.')
    end

    def self.collection
      MongoDoc.database.collection(collection_name)
    end

    def self.count
      collection.count
    end

    def self.create(attrs = {}, safe = false)
      instance = new(attrs)
      instance.valid? and _create(instance, false)
    end
    
    def self.create!(attrs = {})
      instance = new(attrs)
      if instance.valid?
        _create(instance, true)
      else
        raise DocumentInvalidError
      end
    end

    def self.find_one(id)
      MongoDoc::BSON.decode(collection.find_one(id))
    end

    protected

    def _propose_update_attributes(src, attrs, safe)
      if _parent
        _parent.send(:_propose_update_attributes, src, attrs, safe)
      else
        _update_attributes(attrs, safe)
      end
    end

    def _save(safe)
      self._id = self.class.collection.save(self.to_bson, :safe => safe)
    end

    def _update_attributes(attrs,  safe)
      self.class.collection.update({'_id' => self._id}, MongoDoc::Query.set_modifier(attrs.to_bson), :safe => safe)
      result = MongoDoc.database.db_command({'getlasterror' => 1})
      return (result and result.has_key?('updatedExisting') and result['updatedExisting'])
    end

    def self._create(instance, safe)
      instance._id = collection.insert(instance.to_bson, :safe => safe)
      instance
    end
  end
end
