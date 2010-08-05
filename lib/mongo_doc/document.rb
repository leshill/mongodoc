require 'mongo_doc/bson'
require 'mongo_doc/polymorphic_collection'
require 'mongo_doc/attributes'
require 'mongo_doc/root'
require 'mongo_doc/associations'
require 'mongo_doc/criteria'
require 'mongo_doc/finders'
require 'mongo_doc/index'
require 'mongo_doc/scope'
require 'mongo_doc/timestamps'
require 'mongo_doc/references'
require 'mongo_doc/references_many'
require 'active_model'
require 'mongo_doc/validations'

module MongoDoc
  class UnsupportedOperation < RuntimeError; end
  class DocumentInvalidError < RuntimeError; end
  class NotADocumentError < RuntimeError; end

  module Document

    def self.included(klass)
      klass.class_eval do
        include Attributes
        include Root
        extend PolymorphicCollection
        extend Associations
        extend ClassMethods
        extend Criteria
        extend Finders
        extend Index
        extend Scope
        extend Timestamps
        extend References
        extend ReferencesMany
        include ::ActiveModel::Validations
        extend ::ActiveModel::Naming
        extend Validations

        alias id _id
      end
    end

    def _collection
      _root and _root._collection or self.class.collection
    end

    def initialize(attrs = {})
      self.attributes = attrs if attrs
    end

    def ==(other)
      return false unless self.class === other
      self.class._attributes.all? {|var| self.send(var) == other.send(var)}
    end

    def destroyed?
      _id.nil?
    end

    def new_record?
      _id.nil?
    end

    def persisted?
      _id.present?
    end

    def remove
      raise UnsupportedOperation.new('Document#remove is not supported for embedded documents') if _root
      remove_document
    end

    def remove_document
      return _root.remove_document if _root
      _remove
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
        bson_hash['_id'] = _id unless new_record?
        self.class._attributes.each do |name|
          bson_hash[name.to_s] = send(name).to_bson(args)
        end
      end
    end

    def to_key
      persisted? ? [_id] : nil
    end

    def to_model
      self
    end

    def to_param
      persisted? ? _id.to_s : nil
    end

    def update_attributes(attrs)
      self.attributes = attrs
      return save if new_record?
      return false unless valid?
      _update_attributes(attrs, false)
    end

    def update_attributes!(attrs)
      self.attributes = attrs
      return save! if new_record?
      raise DocumentInvalidError unless valid?
      _update_attributes(attrs, true)
    end

    # Update without checking validations. The +Document+ will be saved without validations if it is a new record.
    def update(attrs, safe = false)
      self.attributes = attrs
      if new_record?
        _root.send(:_save, safe) if _root
        _save(safe)
      else
        _update_attributes(attrs, safe)
      end
    end

    module ClassMethods
      def bson_create(bson_hash, options = {})
        allocate.tap do |obj|
          bson_hash.each do |name, value|
            obj.send("#{name}=", MongoDoc::BSON.decode(value, options))
          end
        end
      end

      def collection
        @collection ||= MongoDoc::Collection.new(collection_name)
      end

      def create(attrs = {})
        instance = new(attrs)
        instance.save(true)
        instance
      end

      def create!(attrs = {})
        instance = new(attrs)
        instance.save!
        instance
      end
    end

    protected

    def _update_attributes(attrs, safe)
      return _root.send(:_update, {_selector_path + '._id' => _id}, hash_with_modifier_path_keys(attrs), safe) if _root
      _update({}, attrs, safe)
    end

    def _remove
      _collection.remove({'_id' => _id})
    end

    def _update(selector, data, safe)
      _collection.update({'_id' => _id}.merge(selector), {'$set' => data}, :safe => safe)
    end

    def _save(safe)
      notify_before_save_observers
      self._id = _collection.save(self, :safe => safe)
      notify_save_success_observers
      self._id
    rescue Mongo::MongoDBError => e
      notify_save_failed_observers
      raise e
    end

    def hash_with_modifier_path_keys(hash)
      hash.stringify_keys!
      {}.tap do |dup|
        hash.each do |key, value|
          dup[_modifier_path + '.' + key] = value
        end
      end
    end

    def path(parent_path, child_path)
      if parent_path.blank?
        child_path
      else
        parent_path + '.' + child_path
      end
    end

    def before_save_callback(root)
      self._id = ::BSON::ObjectID.new if new_record?
    end

    def save_failed_callback(root)
      self._id = nil
    end

    def save_success_callback(root)
      root.unregister_save_observer(self)
    end

    def save_observers
      @save_observers ||= []
    end

    def register_save_observer(child)
      save_observers << child
    end

    def unregister_save_observer(child)
      save_observers.delete(child)
    end

    def notify_before_save_observers
      save_observers.each {|obs| obs.before_save_callback(self) }
    end

    def notify_save_success_observers
      save_observers.each {|obs| obs.save_success_callback(self) }
    end

    def notify_save_failed_observers
      save_observers.each {|obs| obs.save_failed_callback(self) }
    end
  end
end
