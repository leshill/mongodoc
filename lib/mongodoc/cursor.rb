module MongoDoc
  class Cursor
    include Enumerable

    attr_accessor :_cursor
    delegate :close, :closed?, :count, :explain, :limit, :query_options_hash, :query_opts, :skip, :sort, :to => :_cursor

    def initialize(cursor)
      self._cursor = cursor
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
