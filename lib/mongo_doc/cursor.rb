module MongoDoc
  class Cursor
    include Enumerable

    attr_accessor :_collection, :_cursor

    delegate :admin, :close, :closed?, :count, :explain, :fields, :full_collection_name, :hint, :limit, :order, :query_options_hash, :query_opts, :selector, :skip, :snapshot, :sort, :timeout, :to => :_cursor

    def initialize(mongo_doc_collection, cursor)
      self._collection = mongo_doc_collection
      self._cursor = cursor
    end

    def collection
      _collection
    end

    def each
      _cursor.each do |next_document|
        yield MongoDoc::BSON.decode(next_document)
      end
    end

    def next_document
      MongoDoc::BSON.decode(_cursor.next_document)
    end

    def to_a
      MongoDoc::BSON.decode(_cursor.to_a)
    end
  end
end
