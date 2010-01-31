module MongoDoc
  module Associations
    class DocumentProxy < ProxyBase

      attr_reader :document

      def _root=(root)
        @_root = root
        document._root = root if is_document?(document)
      end

      def ==(other)
        if self.class === other
          document == other.document
        else
          document == other
        end
      end

      def build(attrs)
        item = assoc_class.new(attrs)
        self.document = item
      end

      def document=(doc)
        attach(doc)
        @document = doc
      end

      def valid?
        if is_document?(document)
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
