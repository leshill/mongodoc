require 'mongodoc/exceptions'
require 'mongodoc/bson'
require 'mongodoc/connection'
require 'mongodoc/value_equals'

module MongoDoc
  module Document
    module Identity
      attr_accessor :_id
      alias :id :_id
      alias :to_param :_id

      def new_record?
        _id.nil?
      end
    end

    module Keys
      def self.extended(klass)
        klass.class_inheritable_array :_keys
        klass._keys = []
      end

      def key(*args)
        args.each do |name|
          _keys << name unless _keys.include?(name)
          attr_accessor name
        end
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
    extend MongoDoc::Document::Keys
    extend MongoDoc::Document::BSONCreate
    include MongoDoc::Document::ToBSON
    include MongoDoc::ValueEquals
    include MongoDoc::Document::Identity
    
    def save
      self._id = self.class.collection.save(self.to_bson)
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

    def self.find_one(id)
      MongoDoc::BSON.decode(collection.find_one(id))
    end
  end
end
