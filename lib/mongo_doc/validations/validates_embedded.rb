module MongoDoc
  module Validations
    class ValidatesEmbedded < ::Validatable::ValidationBase
      def valid?(instance)
        instance.send(attribute).valid?
      end

      def message(instance)
        super || "is invalid"
      end
    end
  end
end
