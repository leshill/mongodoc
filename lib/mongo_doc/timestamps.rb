module MongoDoc
  module Timestamps

    # Create automatic timestamps on a +root+ Document. Timestamps are not
    # implemented for embedded documents.
    #
    # Two timestamps fields are created: +created_at+, +updated_at+
    #
    # +created_at+:: set on initial save only
    # +updated_at+:: set on every save
    def timestamps!
      [:created_at, :updated_at].each do |name|
        _add_key(name)
        attr_reader name
        class_eval(<<-RUBY, __FILE__, __LINE__)
          def #{name}=(value)                       # def created_at=(value)
            if value.kind_of?(String)               #   if value.kind_of?(String)
              value = Time.cast_from_string(value)  #     value = Time.cast_from_string(value)
            end                                     #   end
            @#{name} = value.nil? ? nil : value.utc #   @created_at = value.nil? ? nil : value.utc
          end                                       # end
        RUBY
      end

      class_eval(<<-RUBY, __FILE__, __LINE__)
        def _save(safe)
          if new_record?
            self.created_at = self.updated_at = Time.now
          else
            original_updated_at = updated_at
            self.updated_at = Time.now
          end
          super
        rescue Mongo::MongoDBError => e
          if new_record?
            self.created_at = self.updated_at = nil
          else
            self.updated_at = original_updated_at
          end
          raise e
        end

        def _update(selector, data, safe)
          original_updated_at = updated_at
          self.updated_at = Time.now
          data[:updated_at] = updated_at
          super
        rescue Mongo::MongoDBError => e
          self.updated_at = original_updated_at
          raise e
        end
      RUBY
    end
  end
end
