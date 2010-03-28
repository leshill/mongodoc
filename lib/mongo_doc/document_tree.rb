module MongoDoc
  module DocumentTree

    attr_accessor :_parent
    attr_reader :_root

    def _path_to_root
      return '' unless _parent
      _parent._path_to_root
    end

    def _update_path_to_root
      return '' unless _parent
      _parent._update_path_to_root
    end

    def _root=(root)
      @_root = root
      _associations.each do|a|
        association = send(a)
        association._root = root if association
      end
    end
  end
end
