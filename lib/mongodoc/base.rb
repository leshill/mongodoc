require 'mongodoc/bson'
require 'mongodoc/connection'
require 'mongodoc/value_equals'
require 'mongodoc/query'
require 'mongodoc/attributes'

module MongoDoc
  module Document
    class NotADocumentError < RuntimeError; end

    def self.included(klass)
      klass.instance_eval do
        extend MongoDoc::Document::Attributes
        extend MongoDoc::Document::BSONCreate
        include MongoDoc::Document::ToBSON
        include MongoDoc::Document::ValueEquals
        include MongoDoc::Document::Identity
      end
    end

    module ValueEquals
      def ==(other)
        return false unless instance_variables.size == other.instance_variables.size
        (instance_variables - ["@_parent", "@_root"]).all? {|var| self.instance_variable_get(var) == other.instance_variable_get(var)}
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
          self.class._keys.each do |name|
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
    
    def save(safe = false)
      self._id = self.class.collection.save(self.to_bson, :safe => safe)
    end
    
    def save!
      save(true)
    end

    def update_attributes(attrs, safe = false)
      self.attributes = attrs
      self.class.collection.update({'_id' => self._id}, MongoDoc::Query.set_modifier(attrs.to_bson), :safe => safe)
    end
    
    def update_attributes!(attrs)
      update_attributes(attrs, true)
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
      instance._id = collection.insert(instance.to_bson, :safe => safe)
      instance
    end
    
    def self.create!(attrs = {})
      create(attrs, true)
    end

    def self.find_one(id)
      MongoDoc::BSON.decode(collection.find_one(id))
    end
  end
end
