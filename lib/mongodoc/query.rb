module MongoDoc
  module Query
    def self.set_modifier(bson_hash)
      {'$set' => bson_hash}
    end
  end
end