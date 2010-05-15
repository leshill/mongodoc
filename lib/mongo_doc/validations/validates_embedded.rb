module MongoDoc
  module Validations
    module ValidatesEmbedded
      def validates_embedded(*attr_names)
        validates_with EmbeddedValidator, _merge_attributes(attr_names)
      end

      class EmbeddedValidator < ::ActiveModel::EachValidator
        def validate(record)
          attributes.each do |attr|
            record.errors.add(attr) unless record.send(attr).valid?
          end
        end
      end
    end
  end
end
