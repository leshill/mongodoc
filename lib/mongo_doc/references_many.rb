module MongoDoc
  module ReferencesMany

    def self.ids_from_objects(objects)
      if objects.blank?
        []
      else
        objects.map {|obj| obj._id }
      end
    end

    def self.ids_from_strings_or_ids(ids_or_strings)
      if ids_or_strings.blank?
        []
      else
        ids_or_strings.map do |item|
          if String === item
            ::BSON::ObjectId.cast_from_string(item)
          else
            item
          end
        end
      end
    end

    def self.objects_from_ids(klass, ids)
      if ids.blank?
        []
      else
        klass.find(*ids).entries
      end
    end

    def self.objects_from_refs(refs)
      if refs.blank?
        []
      else
        refs.map {|ref| References.dereference(ref) }
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
    # +ObjectId+ references or a +BSON::DBRef+, but cannot be both.
    #
    # Use an +ObjectId+ reference when you have a simple reference or will be
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
        references_many_by_id(klass, options[:as].try(:to_s) || klass.demodulize.underscore.pluralize)
      end
    end

    private

    def references_many_by_dbref(objects_name)
      refs_name = "#{objects_name.singularize}_refs".to_sym

      _add_key(refs_name)

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
      ids_name = "#{objects_name.singularize}_ids".to_sym

      _add_key(ids_name)

      module_eval(<<-RUBY, __FILE__, __LINE__)
        def #{objects_name}=(objects)                                 # def addresses=(objects)
          @#{objects_name} = objects                                  #   @addresses = objects
          self.#{ids_name} = ReferencesMany.ids_from_objects(objects) #   self.address_ids = ReferencesMany.ids_from_objects(objects)
        end                                                           # end

        def #{objects_name}                                                           # def addresses
          @#{objects_name} ||= ReferencesMany.objects_from_ids(#{klass}, #{ids_name}) #   @addresses||= ReferencesMany.objects_from_ids(Address, address_ids)
        end                                                                           # end

        def #{ids_name}=(ids_or_strings)                                        # def address_ids=(ids_or_strings)
          @#{objects_name} = nil                                                #   @addresses = nil
          @#{ids_name} = ReferencesMany.ids_from_strings_or_ids(ids_or_strings) #   @address_ids = ReferencesMany.ids_from_strings_or_ids(ids_or_strings)
        end                                                                     # end

        def #{ids_name}       # def address_ids
          @#{ids_name} ||= [] #  @address_ids ||= []
        end                   # end
      RUBY
    end
  end
end
