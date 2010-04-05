require 'mongo_doc/validations/macros'

module MongoDoc
  module Validations
    def self.included(klass)
      klass.class_eval do
        include ::Validatable
        extend Macros
      end
    end
  end
end
