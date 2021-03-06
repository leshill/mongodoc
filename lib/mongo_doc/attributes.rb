module MongoDoc
  module Attributes
    def self.included(klass)
      klass.class_eval do
        class_attribute :_keys
        self._keys = []
        class_attribute :_associations
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
      (attrs || {}).each do |key, value|
        send("#{key}=", value)
      end
    end

    module ClassMethods

      def self.extended(klass)
        klass.class_eval do
          singleton_class.alias_method_chain :attr_accessor, :mongo
        end
      end

      def _add_key(key)
        self._keys += [key] unless _keys.include?(key)
      end

      def _add_association(association)
        self._associations += [association] unless _associations.include?(association)
      end

      def _attributes
        _keys + _associations
      end

      def attr_accessor_with_mongo(*args)
        return attr_accessor_without_mongo(*args) if args.first == :validation_context
        opts = args.extract_options!
        default = opts.delete(:default)
        type = opts.delete(:type)
        args.each do |name|
          _add_key(name)
          attr_writer name

          unless default.nil?
            define_method("_default_#{name}", default.kind_of?(Proc) ? default : proc { default.duplicable? ? default.dup : default })
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

          if type == Boolean
            module_eval(<<-RUBY, __FILE__, __LINE__)
              alias #{name}? #{name}  # alias active? active
            RUBY
          end

          if type.try(:respond_to?, :cast_from_string)
            define_method "#{name}_with_type=" do |value|
              if value.kind_of?(String)
                value = type.cast_from_string(value)
              end
              self.send("#{name}_without_type=", value)
            end
            alias_method_chain "#{name}=", :type
          end
        end
      end
      alias key attr_accessor_with_mongo

    end
  end
end
