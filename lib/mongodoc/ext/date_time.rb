class DateTime
  def to_bson(*args)
    {
      MongoDoc::JSON::CLASS_KEY => self.class.name,
      'dt' => strftime,
      'sg' => start
    }
  end

  def self.object_create(bson_hash, options = nil)
    DateTime.parse(*bson_hash.values_at('dt', 'sg'))
  end
end
