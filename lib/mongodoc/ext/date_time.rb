class DateTime
  def to_json(*args)
    {
      MongoDoc::JSON::CLASS_KEY => self.class.name,
      'dt' => strftime,
      'sg' => start
    }
  end

  def self.object_create(json_hash, options = nil)
    DateTime.parse(*json_hash.values_at('dt', 'sg'))
  end
end
