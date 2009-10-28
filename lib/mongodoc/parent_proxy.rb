module MongoDoc
  module Document
    class ParentProxy
      attr_reader :assoc_name, :_parent

      def initialize(parent, assoc_name)
        @_parent = parent
        @assoc_name = assoc_name
      end
      
      def path_to_root(prev)
        _parent.path_to_root(assoc_name => prev)
      end
    end
  end
end