require 'mongodoc/exceptions'
require 'mongodoc/bson'
require 'mongodoc/connection'

module MongoDoc
  class Base
    include MongoDoc::BSON::InstanceMethods
    extend MongoDoc::BSON::ClassMethods
    
    class_inheritable_array :keys
    self.keys = []

    def self.key(name)
      keys << name
      
      define_method(name) do
        instance_variable_get("@#{name}")
      end

      define_method(name.to_s + '=') do |value|
        instance_variable_set("@#{name}", value)
      end
    end
    
    def self.collection
      MongoDoc.database.collection(self.to_s.tableize.gsub('/', '.'))
    end
    
  end
end