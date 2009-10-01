class Date
  def to_json(*args)
    {
      MongoDoc::JSON::CLASS_KEY => self.class.name,
      'dt' => strftime,
      'sg' => start
    }
  end

  alias start sg unless method_defined?(:start)

  def self.object_create(json_hash, options = nil)
    Date.parse(*json_hash.values_at('dt', 'sg'))
  end

end
