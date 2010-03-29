module MongoDoc
  module Associations
    class DocumentProxy
      include ProxyBase

      attr_reader :document

      delegate :to_bson, :id, :to => :document

      %w(_modifier_path _selector_path).each do |setter|
        class_eval(<<-RUBY, __FILE__, __LINE__)
          def #{setter}=(path)
            super
            document.#{setter} = #{setter} if ProxyBase.is_document?(document)
          end
        RUBY
      end

      def _root=(value)
        @_root = value
        document._root = value if ProxyBase.is_document?(document)
      end

      def ==(other)
        if self.class === other
          document == other.document
        else
          document == other
        end
      end

      def build(attrs)
        item = _assoc_class.new(attrs)
        self.document = item
      end

      def document=(doc)
        attach(doc)
        @document = doc
      end

      def valid?
        if ProxyBase.is_document?(document)
          document.valid?
        else
          true
        end
      end

      private

      def method_missing(method, *args)
        unless document.respond_to?(method)
          raise NoMethodError, "undefined method `#{method.to_s}' for proxied \"#{document}\":#{document.class.to_s}"
        end

        if block_given?
          document.send(method, *args)  { |*block_args| yield(*block_args) }
        else
          document.send(method, *args)
        end
      end
    end
  end
end
