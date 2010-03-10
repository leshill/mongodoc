require 'mongo_doc/ext'

module MongoDoc
  module BSON
    CLASS_KEY = "json_class"

    def self.decode(bson, options = {})
      return bson if options[:raw_json]
      case bson
      when Hash
        bson_create(bson, options)
      when Array
        array_create(bson, options)
      else
        bson
      end
    end

    def self.bson_create(bson_hash, options = {})
      return bson_hash if options[:raw_json]
      klass = bson_hash.delete(CLASS_KEY)
      return bson_hash.each_pair {|key, value| bson_hash[key] = decode(value, options)} unless klass
      klass.constantize.bson_create(bson_hash, options)
    end

    def self.array_create(bson_array, options = {})
      return bson_array if options[:raw_json]
      bson_array.map {|item| decode(item, options)}
    end
  end
end
