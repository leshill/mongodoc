module MongoDoc
  module References
    # Declare a reference to another +Document+.
    #
    # * classname:: name of +Document+ type as an +underscore+ symbol or string
    # * options:: +:as+ specifies the name of the attribute
    def references(classname, options = {})
      klass = classname.to_s.camelize
      attr_name = options[:as] || klass.to_s.demodulize.downcase

      attr_accessor "#{attr_name}_id".to_sym, :type => ::BSON::ObjectID

      module_eval(<<-RUBY, __FILE__, __LINE__)
        def #{attr_name}_id_with_reference=(value)       # def address_id_with_reference=(value)
          @#{attr_name} = nil                            #   @address = nil
          self.#{attr_name}_id_without_reference = value #   self.address_id_without_reference = value
        end                                              # end

        def #{attr_name}
          @#{attr_name} ||= if #{attr_name}_id.nil? # @address ||= if address_name_id.nil?
              nil                                   #     nil
            else                                    #   else
              #{klass}.find_one(#{attr_name}_id)    #     Address.find_one(address_name_id)
            end                                     #   end
        end

        def #{attr_name}=(value)                              # def address=(value)
          @#{attr_name} = value                               # @address = value
          self.#{attr_name}_id = value.nil? ? nil : value._id # self.address_id = value.nil? ? nil : value._id
        end                                                   # end
      RUBY

      alias_method_chain "#{attr_name}_id=", :reference
    end
  end
end
