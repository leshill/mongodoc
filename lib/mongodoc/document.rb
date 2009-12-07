require 'mongodoc/bson'
require 'mongodoc/query'
require 'mongodoc/attributes'
require 'mongodoc/criteria'

module MongoDoc
  class DocumentInvalidError < RuntimeError; end
  class NotADocumentError < RuntimeError; end

  class Document
    extend MongoDoc::Attributes
    include Validatable

    attr_accessor :_id
    alias :id :_id
    alias :to_param :_id

    def initialize(attrs = {})
      self.attributes = attrs
    end

    def ==(other)
      return false unless self.class === other
      self.class._attributes.all? {|var| self.send(var) == other.send(var)}
    end

    def attributes=(attrs)
      attrs.each do |key, value|
        send("#{key}=", value)
      end
    end

    def new_record?
      _id.nil?
    end

    def save(validate = true)
      return _root.save(validate) if _root
      return _save(false) unless validate and not valid?
      false
    end
    
    def save!
      return _root.save! if _root
      raise DocumentInvalidError unless valid?
      _save(true)
    end

    def to_bson(*args)
      {MongoDoc::BSON::CLASS_KEY => self.class.name}.tap do |bson_hash|
        bson_hash['_id'] = _id unless _id.nil?
        self.class._attributes.each do |name|
          bson_hash[name.to_s] = send(name).to_bson(args)
        end
      end
    end

    def update_attributes(attrs)
      self.attributes = attrs
      return _propose_update_attributes(self, path_to_root(attrs), false) if valid?
      false
    end

    def update_attributes!(attrs)
      self.attributes = attrs
      raise DocumentInvalidError unless valid?
      _propose_update_attributes(self, path_to_root(attrs), true)
    end

    class << self
      def bson_create(bson_hash, options = {})
        new.tap do |obj|
          bson_hash.each do |name, value|
            obj.send("#{name}=", MongoDoc::BSON.decode(value, options))
          end
        end
      end

      def collection
        @collection ||= MongoDoc::Collection.new(collection_name)
      end

      def collection_name
        self.to_s.tableize.gsub('/', '.')
      end

      def count
        collection.count
      end

      def create(attrs = {})
        instance = new(attrs)
        _create(instance, false) if instance.valid?
        instance
      end
    
      def create!(attrs = {})
        instance = new(attrs)
        raise MongoDoc::DocumentInvalidError unless instance.valid?
        _create(instance, true)
        instance
      end

      def criteria
        Criteria.new(self)
      end

      def find_one(id)
        MongoDoc::BSON.decode(collection.find_one(id))
      end
    end

    protected

    def _collection
      self.class.collection
    end
    
    def _propose_update_attributes(src, attrs, safe)
      return _parent.send(:_propose_update_attributes, src, attrs, safe) if _parent
      _update_attributes(attrs, safe)
    end

    def _save(safe)
      self._id = _collection.save(self, :safe => safe)
    end

    def _update_attributes(attrs,  safe)
      _collection.update({'_id' => self._id}, MongoDoc::Query.set_modifier(attrs), :safe => safe)
    end

    class << self
      def _create(instance, safe)
        instance._id = collection.insert(instance, :safe => safe)
      end
    end
  end
end
