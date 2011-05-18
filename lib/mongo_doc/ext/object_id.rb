module BSON
  class ObjectId
    def to_bson(*args)
      self
    end

    def self.cast_from_string(string)
      ObjectId.from_string(string) unless string.blank?
    end
  end
end
