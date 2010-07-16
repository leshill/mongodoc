module MongoDoc
  module ReferencesMany
    # Declare an array of references to other +Document+s.
    #
    # * classname:: name of +Document+ type as an +underscore+ symbol or string
    # * options:: +:as+ specifies the name of the attribute
    def references_many(classname, options = {})
      klass = classname.to_s.camelize.singularize
      objects_name = (options[:as] || klass.demodulize.downcase.pluralize).to_s
      ids_name = "#{objects_name.singularize}_ids"

      _keys << ids_name unless _keys.include?(ids_name)

      module_eval(<<-RUBY, __FILE__, __LINE__)
        def #{objects_name}=(array)           # def addresses=(array)
          @#{objects_name} = array            #   @addresses = array
          self.#{ids_name} = array.map(&:_id) #   self.address_ids = array.map(&:_id)
        end                                   # end

        def #{objects_name}                          # def addresses
          @#{objects_name} ||= if #{ids_name}.empty? #   @addresses ||= if address_ids.empty?
              []                                     #     []
            else                                     #   else
              "#{klass}".constantize.                #     "Address".constantize.
                find(*#{ids_name}).entries           #       find(*address_ids).entries
            end                                      #   end
        end

        def #{ids_name}=(array)                           # def address_ids=(array)
          @#{objects_name} = nil                          #   @addresses = nil
          @#{ids_name} = ReferencesMany.cast_array(array) #   @address_ids = ReferencesMany.cast_array(array)
        end                                               # end

        def #{ids_name}       # def address_ids
          @#{ids_name} ||= [] #  @address_ids ||= []
        end                   # end
      RUBY
    end

    def self.cast_array(array)
      array.nil? ? [] : array.map do |item|
        String === item ? ::BSON::ObjectID.cast_from_string(item) : item
      end
    end
  end
end
