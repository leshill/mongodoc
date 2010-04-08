module Mongoid
  module Contexts
    module Ids
      # Return documents based on an id search. Will handle if a single id has
      # been passed or mulitple ids.
      #
      # Example:
      #
      #   context.id_criteria([1, 2, 3])
      #
      # Returns:
      #
      # The single or multiple documents.
      def id_criteria(params)
        criteria.id(strings_to_object_ids(params))
        params.is_a?(Array) ? criteria.entries : one
      end

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
