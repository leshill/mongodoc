class Object
  def to_bson(*args)
    {MongoDoc::BSON::CLASS_KEY => self.class.name}.tap do |bson_hash|
      instance_variables.each do |name|
        bson_hash[name[1..-1]] = instance_variable_get(name).to_bson(args)
      end
    end
  end
  
  def self.bson_create(bson_hash, options = {})
    new.tap do |obj|
      bson_hash.each do |name, value|
        obj.instance_variable_set("@#{name}", MongoDoc::BSON.decode(value, options))
      end
    end
  end
end
