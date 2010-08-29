module MongoDoc
  module ReferencesMany

    def self.cast_array(array)
      array.nil? ? [] : array.map do |item|
        String === item ? ::BSON::ObjectID.cast_from_string(item) : item
      end
    end

    def self.dereference(db_ref)
      MongoDoc::Collection.new(db_ref.namespace).find_one(db_ref.object_id)
    end

    def self.objects_from_refs(refs)
      if refs.blank?
        []
      else
        refs.map {|ref| ReferencesMany.dereference(ref) }
      end
    end

    def self.refs_from_objects(objects)
      if objects.blank?
        []
      else
        objects.map {|obj| ::BSON::DBRef.new(obj.class.collection_name, obj._id) }
      end
    end

    # Declare reference to an array of +Document+s. The references can be
    # +ObjectID+ references or a +BSON::DBRef+, but cannot be both.
    #
    # Use an +ObjectID+ reference when you have a simple reference or will be
    # referencing a single polymorphic collection. Example:
    #
    # +references_many :addresses
    # +references_many :addresses, :as => :work_address+
    #
    # * classname:: name of +Document+ type as an +underscore+ symbol or string
    # * options:: +:as+ specifies the name of the attribute, defaults to
    # classname
    #
    # Use a +BSON::DBRef+ when you need a reference to multiple collections.
    # Example:
    #
    # +references_many :as_ref => :work_address+
    #
    # * required:: +:as_ref+ name of the attribute
    def references_many(*args)
      options = args.extract_options!

      if options.has_key?(:as_ref)
        references_many_by_dbref(options[:as_ref].to_s)
      else
        klass = args[0].to_s.singularize.camelize
        references_many_by_id(klass, options[:as].try(:to_s) || klass.demodulize.downcase.pluralize)
      end
    end

    private

    def references_many_by_dbref(objects_name)
      refs_name = "#{objects_name.singularize}_refs"

      _keys << refs_name unless _keys.include?(refs_name)

      module_eval(<<-RUBY, __FILE__, __LINE__)
        def #{objects_name}=(objects)                                   # def addresses=(objects)
          @#{objects_name} = objects                                    #   @addresses = objects
          self.#{refs_name} = ReferencesMany.refs_from_objects(objects) # self.address_refs = ReferencesMany.refs_from_objects(objects)
        end                                                             # end

        def #{objects_name}                                                   # def addresses
          @#{objects_name} ||= ReferencesMany.objects_from_refs(#{refs_name}) #   @addresses ||= ReferencesMany.objects_from_refs(address_refs)
        end                                                                   # end

        def #{refs_name}=(refs)  # def address_refs=(refs)
          @#{objects_name} = nil #   @addresses = nil
          @#{refs_name} = refs   #   @address_refs = refs
        end                      # end

        def #{refs_name}       # def address_refs
          @#{refs_name} ||= [] #  @address_refs ||= []
        end                    # end
      RUBY
    end

    def references_many_by_id(klass, objects_name)
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
  end
end
