require 'mongo_doc/validations/validates_embedded'

module MongoDoc
  module Validations
    module Macros
      def validates_embedded(*args)
        add_validations(args, MongoDoc::Validations::ValidatesEmbedded)
      end
    end
  end
end
