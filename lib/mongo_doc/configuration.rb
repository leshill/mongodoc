module MongoDoc
  module Configuration
    extend self

    attr_accessor :dynamic_attributes
    self.dynamic_attributes = false
  end
end
