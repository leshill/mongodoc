require 'mongodoc/ext/array'
require 'mongodoc/ext/boolean_class'
require 'mongodoc/ext/date'
require 'mongodoc/ext/date_time'
require 'mongodoc/ext/hash'
require 'mongodoc/ext/nil_class'
require 'mongodoc/ext/numeric'
require 'mongodoc/ext/object'
require 'mongodoc/ext/regexp'
require 'mongodoc/ext/string'
require 'mongodoc/ext/symbol'
require 'mongodoc/ext/time'

module MongoDoc
  module JSON
    CLASS_KEY = "json_class"

    def self.decode(json, options = {})
      return json if options[:raw_json]
      case json
      when Hash
        object_create(json, options)
      when Array
        array_create(json, options)
      else
        json
      end
    end
    
    def self.object_create(json_hash, options = {})
      return json_hash if options[:raw_json]
      klass = json_hash.delete(CLASS_KEY)
      return json_hash.each_pair {|key, value| json_hash[key] = decode(value)} unless klass
      klass.constantize.object_create(json_hash, options)
    end

    def self.array_create(json_array, options = {})
      return json_array if options[:raw_json]
      json_array.map {|item| decode(item, options)}
    end

    module InstanceMethods
      def to_json(*args)
        {MongoDoc::JSON::CLASS_KEY => self.class.name}.tap do |json_hash|
          self.class.keys.each do |name|
            json_hash[name.to_s] = send(name).to_json
          end
        end
      end
    end

    module ClassMethods
      def self.object_create(json_hash, options = {})
        new.tap do |obj|
          json_hash.each do |name, value|
            obj.send("#{name}=", MongoDoc::JSON.decode(value))
          end
        end
      end
    end
  end
end