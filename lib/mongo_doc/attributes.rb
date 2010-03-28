module MongoDoc
  module Attributes
    def self.included(klass)
      klass.class_eval do
        class_inheritable_array :_keys
        self._keys = []
        class_inheritable_array :_associations
        self._associations = []

        attr_accessor :_id

        extend ClassMethods
      end
    end

    def attributes
      hash = {}
      self.class._attributes.each do |attr|
        hash[attr] = send(attr)
      end
      hash
    end

    def attributes=(attrs)
      attrs.each do |key, value|
        send("#{key}=", value)
      end
    end

    module ClassMethods

      def self.extended(klass)
        klass.class_eval do
          metaclass.alias_method_chain :attr_accessor, :mongo
        end
      end

      def _attributes
        _keys + _associations
      end

      def attr_accessor_with_mongo(*args)
        opts = args.extract_options!
        default = opts.delete(:default)
        type = opts.delete(:type)
        args.each do |name|
          _keys << name unless _keys.include?(name)
          attr_writer name

          if default
            define_method("_default_#{name}", default.kind_of?(Proc) ? default : proc { default })
            private "_default_#{name}"

            module_eval(<<-RUBY, __FILE__, __LINE__)
              def #{name}                                # def birth_date
                unless defined? @#{name}                 #   unless defined? @birth_date
                  @#{name} = _default_#{name}            #     @birth_date = _default_birth_date
                end                                      #   end
                class << self; attr_reader :#{name} end  #   class << self; attr_reader :birth_date end
                @#{name}                                 #   @birth_date
              end                                        # end
            RUBY
          else
            attr_reader name
          end

          if type and type.respond_to?(:cast_from_string)
            module_eval(<<-RUBY, __FILE__, __LINE__)
              def #{name}_with_type=(value)               # def birth_date_with_type=(value)
                if value.kind_of?(String)                 #   if value.kind_of?(String)
                  value = #{type}.cast_from_string(value) #     value = Date.cast_from_string(value)
                end                                       #   end
                self.#{name}_without_type = value         #   self.birth_date_without_type = value
              end                                         # end
            RUBY
            alias_method_chain "#{name}=", :type
          end
        end
      end
      alias key attr_accessor_with_mongo

    end
  end
end
