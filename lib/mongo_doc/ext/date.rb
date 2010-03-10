class Date
  def to_bson(*args)
    {
      MongoDoc::BSON::CLASS_KEY => self.class.name,
      'dt' => strftime,
      'sg' => start
    }
  end

  alias start sg unless method_defined?(:start)

  def self.bson_create(bson_hash, options = nil)
    Date.parse(*bson_hash.values_at('dt', 'sg'))
  end

  def self.cast_from_string(value)
    Date.parse(value) unless value.blank?
  end
end
