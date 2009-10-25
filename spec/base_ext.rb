module MongoDoc
  class Base
    def errors_on(attribute)
      self.valid?
      [self.errors.on(attribute)].flatten.compact
    end
    alias :error_on :errors_on
  end
end