require 'mongodoc/exceptions'
require 'mongodoc/json'
require 'mongodoc/connection'

module MongoDoc
  class Base
    include MongoDoc::JSON::InstanceMethods
    extend MongoDoc::JSON::ClassMethods
    
    class_inheritable_array :keys
    self.keys = []

    def self.key(name)
      keys << name
      
      define_method(name) do
        read_attribute(name)
      end

      define_method(name.to_s + '=') do |value|
        write_attribute(name, value)
      end
    end
    
    def self.collection
      MongoDoc.database.collection(self.to_s.tableize.gsub('/', '.'))
    end
    
    private
    
    def read_attribute(name)
      instance_variable_get("@#{name}")
    end
    
    def write_attribute(name, value)
      instance_variable_set("@#{name}", value)
    end
  end
end