module MongoDoc
  module References

    # Dereference a DBRef and return the Object
    def self.dereference(db_ref)
      MongoDoc::Collection.new(db_ref.namespace).find_one(db_ref.object_id)
    end

    # Declare a reference to another +Document+. The reference can either be an
    # +ObjectId+ reference, or a +BSON::DBRef+
    #
    # Use an +ObjectId+ reference when you have a simple reference or will be
    # referencing a single polymorphic collection. Example:
    #
    # +references :address
    # +references :address, :as => :work_address+
    #
    # * classname:: name of +Document+ type as an +underscore+ symbol or string
    # * options:: +:as+ specifies the name of the attribute, defaults to
    # classname
    #
    # Use a +BSON::DBRef+ when you need a reference to multiple collections.
    # Example:
    #
    # +references :as_ref => :work_address+
    #
    # * options:: +:as_ref+ name of the attribute
    def references(*args)
      options = args.extract_options!

      if options.has_key?(:as_ref)
        references_by_dbref(options[:as_ref])
      else
        klass = args[0].to_s.camelize
        references_by_id(klass, options[:as] || klass.to_s.demodulize.underscore)
      end
    end

    private

    def references_by_id(klass, attr_name)
      attr_accessor "#{attr_name}_id".to_sym, :type => ::BSON::ObjectId

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

    def references_by_dbref(name)
      attr_accessor "#{name}_ref".to_sym, :type => ::BSON::DBRef

      module_eval(<<-RUBY, __FILE__, __LINE__)
        def #{name}_ref_with_reference=(value)       # def address_ref_with_reference=(value)
          @#{name} = nil                             #   @address = nil
          self.#{name}_ref_without_reference = value #   self.address_ref_without_reference = value
        end                                          # end

        def #{name}
          @#{name} ||= if #{name}_ref.nil?        # @address ||= if address_name_ref.nil?
              nil                                 #     nil
            else                                  #   else
              References.dereference(#{name}_ref) #     References.dereference(address_name_ref)
            end                                   #   end
        end

        def #{name}=(value)                                  # def address=(value)
          @#{name} = value                                   # @address = value
          self.#{name}_ref = if value.nil?                   # self.address_ref = if value.nil?
              nil                                            #     nil
            else                                             #   else
              ::BSON::DBRef.new(value.class.collection_name, #     ::BSON::DBRef.new(value.collection_name,
                value._id)                                   #       value._id)
            end                                              #   end
        end                                                  # end
      RUBY

      alias_method_chain "#{name}_ref=", :reference
    end
  end
end
