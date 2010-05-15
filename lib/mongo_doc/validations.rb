require 'mongo_doc/validations/validates_embedded'

module MongoDoc
  module Validations
    def self.extended(klass)
      klass.extend MongoDoc::Validations::ValidatesEmbedded
    end
  end
end
