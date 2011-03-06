require 'mongo_doc/cursor'
require 'mongo_doc/criteria'

module MongoDoc
  class Collection
    attr_accessor :_collection

    include MongoDoc::Criteria

    delegate \
      :[],
      :clear,
      :count,
      :create_index,
      :db,
      :distinct,
      :drop,
      :drop_index,
      :drop_indexes,
      :group,
      :hint,
      :index_information,
      :map_reduce,
      :mapreduce,
      :name,
      :options,
      :pk_factory,
      :remove,
      :rename,
      :size, :to => :_collection

    def initialize(name)
      self._collection = self.class.mongo_collection(name)
    end

    def find(query = {}, options = {})
      cursor = wrapped_cursor(query, options)
      if block_given?
        yield cursor
        cursor.close
      else
        cursor
      end
    end

    def find_and_modify(opts)
      MongoDoc::BSON.decode(_collection.find_and_modify(opts))
    end

    def find_one(spec_or_object_id = nil, options = {})
      MongoDoc::BSON.decode(_collection.find_one(spec_or_object_id, options))
    end

    def insert(doc_or_docs, options = {})
      _collection.insert(doc_or_docs.to_bson, options)
    end
    alias << insert

    def save(doc, options = {})
      _collection.save(doc.to_bson, options)
    end

    def update(spec, doc, options = {})
      _collection.update(spec, doc.to_bson, options)
      (last_error || {})['updatedExisting'] || false
    end

    protected

    def collection
      self
    end

    def last_error
      MongoDoc::Connection.database.command({'getlasterror' => 1})
    end

    def wrapped_cursor(query = {}, options = {})
      MongoDoc::Cursor.new(self, _collection.find(query, options))
    end

    def self.mongo_collection(name)
      MongoDoc::Connection.database.collection(name)
    end
  end
end
