module Mongo
  class ObjectID
    def to_bson(*args)
      self
    end
  end
end