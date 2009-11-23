module MongoDoc
  class Collection
    attr_accessor :_collection
    delegate :[], :clear, :count, :create_index, :db, :drop, :drop_index, :drop_indexes, :group, :hint, :index_information, :name, :options, :remove, :to => :_collection
    
    def initialize(name)
      self._collection = self.class.mongo_collection(name)
    end
    
    def find(query = {}, options = {}, &block)
      MongoDoc::BSON.decode(_collection.find(query, options, &block).to_a)
    end
    
    def find_one(spec_or_object_id = nil, options = {})
      MongoDoc::BSON.decode(_collection.find_one(spec_or_object_id, options))
    end
    
    def insert(doc_or_docs, options = {})
      _collection.insert(doc_or_docs.to_bson, options)
    end
    alias :<< :insert
    
    def save(doc, options = {})
      _collection.save(doc.to_bson, options)
    end
    
    def update(spec, doc, options = {})
      _collection.update(spec, doc.to_bson, options)
      result = MongoDoc.database.db_command({'getlasterror' => 1})
      (result and result.has_key?('updatedExisting')) ? result['updatedExisting'] : false
    end
    
    def self.mongo_collection(name)
      MongoDoc.database.collection(name)
    end
  end
end