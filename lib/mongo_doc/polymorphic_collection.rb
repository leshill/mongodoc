module MongoDoc
  module PolymorphicCollection

    def collection_name(name = nil)
      @_collection_name ||= determine_collection_name(name && name.to_s)
    end

    private

    def _parentclass(parentclass = nil)
      @_parentclass ||= parentclass
    end

    def default_collection_name
      self.to_s.tableize.gsub('/', '.')
    end

    def determine_collection_name(name)
      name || find_collection_name
    end

    def find_collection_name
      _parentclass.try(:collection_name) || default_collection_name
    end

    def inherited(subklass)
      super
      subklass.send(:_parentclass, self)
    end

  end
end
