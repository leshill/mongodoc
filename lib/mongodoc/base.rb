require 'mongodoc/exceptions'
require 'mongodoc/bson'
require 'mongodoc/connection'
require 'mongodoc/value_equals'

module MongoDoc
  class Base
    include MongoDoc::BSON::InstanceMethods
    extend MongoDoc::BSON::ClassMethods
    include MongoDoc::ValueEquals
    
    class_inheritable_array :keys
    self.keys = []

    attr_accessor :_id

    def new_record?
      _id.nil?
    end

    def save
      self._id = self.class.collection.save(self.to_bson)
      self
    end

    def self.key(name)
      keys << name
      
      define_method(name) do
        instance_variable_get("@#{name}")
      end

      define_method(name.to_s + '=') do |value|
        instance_variable_set("@#{name}", value)
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

    def self.find_one(id)
      MongoDoc::BSON.decode(collection.find_one(id))
    end
  end
end
