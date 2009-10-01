class DateTime
  def to_bson(*args)
    {
      MongoDoc::BSON::CLASS_KEY => self.class.name,
      'dt' => strftime,
      'sg' => start
    }
  end

  def self.bson_create(bson_hash, options = nil)
    DateTime.parse(*bson_hash.values_at('dt', 'sg'))
  end
end
