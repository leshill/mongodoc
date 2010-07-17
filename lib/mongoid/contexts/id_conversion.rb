module Mongoid
  module Contexts
    module IdConversion
      protected

      # Convert ids from strings to +BSON::ObjectID+s
      def strings_to_object_ids(ids)
        if Array === ids
          ids.map {|id| string_to_object_id(id) }
        else
          string_to_object_id(ids)
        end

      end

      # Convert ids from strings to +BSON::ObjectID+s
      def string_to_object_id(id)
        if String === id
          ::BSON::ObjectID.from_string(id)
        else
          id
        end
      end
    end
  end
end
