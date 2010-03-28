require 'spec_helper'

describe "MongoDoc::Document" do

  describe "#_collection" do
    class DocumentCollectionTest
      include MongoDoc::Document
    end

    let(:doc) do
      doc = DocumentCollectionTest.new
      doc._root = stub
      doc
    end

    before do
      DocumentCollectionTest.stub(:collection).and_return('collection')
    end

    it "delegates to the root's collection" do
      doc._root.should_receive :_collection
      doc._collection
    end
  end

  context "satisfies form_for requirements" do
    class FormForTest
      include MongoDoc::Document

      attr_accessor :data
    end

    before do
      @doc = FormForTest.new
      @doc._id = '1'
    end

    it "#id returns the _id" do
      @doc.id.should == @doc._id
    end

    it "#to_param returns the string of the _id" do
      @doc.to_param.should == @doc._id.to_s
    end

    context "#new_record?" do
      it "is true when the object does not have an _id" do
        @doc._id = nil
        @doc.should be_new_record
      end

      it "is false when the object has an id" do
        @doc.should_not be_new_record
      end
    end

    it "#initialize takes a hash" do
      data = 'data'
      FormForTest.new(:data => data).data.should == data
    end
  end

  context "validations" do
    class SimpleValidationTest
      include MongoDoc::Document

      attr_accessor :data
      validates_presence_of :data
    end

    it "are included by MongoDoc::Document" do
      Validatable.should === SimpleValidationTest.new
    end

    it "valid? fails when a document is invalid" do
      doc = SimpleValidationTest.new
      doc.should_not be_valid
      doc.should have(1).error_on(:data)
    end
  end

  context "saving" do
    class SaveRoot
      include MongoDoc::Document

      embed_many :save_children
    end

    class SaveChild
      include MongoDoc::Document

      attr_accessor :data
    end

    before do
      @root = SaveRoot.new
      @root.stub(:_save)
      @child = SaveChild.new
      @root.save_children << @child
    end

    context "#save" do
      it "delegates to the root" do
        validate = true
        @root.should_receive(:save).with(validate)
        @child.save(validate)
      end

      context "when validating" do
        it "validates" do
          @root.should_receive(:valid?)
          @root.save(true)
        end

        context "and valid" do
          it "delegates to _save" do
            @root.should_receive(:_save).with(false)
            @root.save(true)
          end

          it "returns the result of _save if valid" do
            id = 'id'
            @root.stub(:valid?).and_return(true)
            @root.should_receive(:_save).and_return(id)
            @root.save(true).should == id
          end
        end

        context "and invalid" do
          it "does not call _save" do
            @root.stub(:valid?).and_return(false)
            @root.should_not_receive(:_save)
            @root.save(true)
          end

          it "returns false" do
            @root.stub(:valid?).and_return(false)
            @root.save(true).should be_false
          end
        end
      end

      context "when not validating" do
        it "does not validate" do
          @root.should_not_receive(:valid?)
          @root.save(false)
        end

        it "delegates to _save" do
          @root.should_receive(:_save).with(false)
          @root.save(false)
        end

        it "returns the result of _save" do
          id = 'id'
          @root.stub(:_save).and_return(id)
          @root.save(false).should == id
        end
      end
    end

    context "#save!" do
      it "delegates to the root" do
        @root.should_receive(:save!)
        @child.save!
      end

      it "validates" do
        @root.should_receive(:valid?).and_return(true)
        @root.save!
      end

      it "returns the result of _save if valid" do
        id = 'id'
        @root.stub(:valid?).and_return(true)
        @root.should_receive(:_save).with(true).and_return(id)
        @root.save!.should == id
      end

      it "raises if invalid" do
        @root.stub(:valid?).and_return(false)
        expect do
          @root.save!
        end.should raise_error(MongoDoc::DocumentInvalidError)
      end
    end
  end

  context "#_save" do
    class SaveTest
      include MongoDoc::Document
    end

    before do
      @collection = stub('collection')
      @doc = SaveTest.new
      @doc.stub(:_collection).and_return(@collection)
    end

    it "delegates to the collection save" do
      safe = true
      @collection.should_receive(:save)
      @doc.send(:_save, safe)
    end

    it "sets the _id of the document" do
      id = 'id'
      @collection.stub(:save).and_return(id)
      @doc.send(:_save, true)
      @doc._id.should == id
    end

    it "returns the _id" do
      id = 'id'
      @collection.stub(:save).and_return(id)
      @doc.send(:_save, true).should == id
    end
  end

  context "creating" do
    class CreateTest
      include MongoDoc::Document

      attr_accessor :data
      validates_presence_of :data
    end

    let(:data) { 'data' }
    let(:instance) { CreateTest.new(:data => data) }

    before do
      instance.stub(:save)
      instance.stub(:save!)
    end

    context ".create" do
      it "creates a new document with the attributes" do
        CreateTest.should_receive(:new).with(:data => data).and_return(instance)
        CreateTest.create(:data => data)
      end

      context "with the new document" do
        before do
          CreateTest.stub(:new).and_return(instance)
        end

        it "calls save on the instance with validate => true" do
          instance.should_receive(:save).with(true)
          CreateTest.create(:data => data)
        end

        it "returns the new object" do
          CreateTest.create(:data => data).should == instance
        end
      end
    end

    context ".create!" do
      it "creates a new document with the attributes" do
        CreateTest.should_receive(:new).with(:data => data).and_return(instance)
        CreateTest.create!(:data => data)
      end

      context "with the new document" do
        before do
          CreateTest.stub(:new).and_return(instance)
        end

        it "calls save! on the instance" do
          instance.should_receive(:save!).with(no_args)
          CreateTest.create!(:data => data)
        end

        it "returns the new object" do
          CreateTest.create!(:data => data).should == instance
        end
      end
    end
  end

  context "updating attributes" do
    class UpdateAttributesChild
      include MongoDoc::Document

      attr_accessor :child_data
    end

    class UpdateAttributes
      include MongoDoc::Document

      attr_accessor :data
      embed :child
    end

    let(:collection) { stub(:update => nil) }

    let(:new_doc) { UpdateAttributes.new }

    let(:existing_doc) do
      doc = UpdateAttributes.new
      doc._id = 'exists'
      doc.stub(:_collection).and_return(collection)
      doc
    end

    let(:child) do
      child = UpdateAttributesChild.new
      child._id = 'child exists'
      existing_doc.child = child
      child
    end

    describe "#update_attributes" do
      it "delegates to save if the doc is a new record" do
        new_doc.should_receive(:save)
        new_doc.update_attributes(:data => 'data')
      end

      context "with an existing doc" do

        subject { existing_doc.update_attributes(:data => 'data') }

        it "sets the attributes" do
          subject
          existing_doc.data.should == 'data'
        end

        it "validates the doc" do
          existing_doc.should_receive(:valid?)
          subject
        end

        it "returns false if the doc is not valid" do
          existing_doc.stub(:valid?).and_return(false)
          should be_false
        end

        it "delegates to collection update" do
          collection.should_receive(:update).with({'_id' => existing_doc._id}, {'$set' => {:data => 'data'}}, :safe => false)
          subject
        end

        context "that is embedded" do
          it "delegates to the root's collection update" do
            collection.should_receive(:update).with({'_id' => existing_doc._id, 'child._id' => child._id}, {'$set' => {'child.child_data' => 'data'}}, :safe => false)
            child.update_attributes(:child_data => 'data')
          end
        end
      end
    end

    describe "#update_attributes!" do
      it "delegates to save! if the doc is a new record" do
        new_doc.should_receive(:save!)
        new_doc.update_attributes!(:data => 'data')
      end

      context "with an existing doc" do

        subject { existing_doc.update_attributes!(:data => 'data') }

        it "sets the attributes" do
          subject
          existing_doc.data.should == 'data'
        end

        it "validates the doc" do
          existing_doc.should_receive(:valid?).and_return(true)
          subject
        end

        it "raises if not valid" do
          existing_doc.stub(:valid?).and_return(false)
          expect do
            subject
          end.should raise_error(MongoDoc::DocumentInvalidError)
        end

        it "delegates to collection update" do
          collection.should_receive(:update).with({'_id' => existing_doc._id}, {'$set' => {:data => 'data'}}, :safe => true)
          subject
        end

        context "that is embedded" do
          it "delegates to the root's collection update" do
            collection.should_receive(:update).with({'_id' => existing_doc._id, 'child._id' => child._id}, {'$set' => {'child.child_data' => 'data'}}, :safe => true)
            child.update_attributes!(:child_data => 'data')
          end
        end
      end
    end

    describe "#_full_path_for_keys" do
      it "returns a stringified hash for when there is no path" do
        new_doc.send(:_full_path_for_keys, :name => 1).should == {'name' => 1}
      end

      it "returns a hash with the keys having a full path to the root" do
        new_doc.stub(:_update_path_to_root).and_return('path.to.root')
        new_doc.send(:_full_path_for_keys, :name => 1).should == {'path.to.root.name' => 1}
      end
    end
  end

  describe "bson" do
    class BSONTest
      include MongoDoc::Document

      attr_accessor :other
    end

    class BSONDerived < BSONTest
      include MongoDoc::Document

      attr_accessor :derived
    end

    class OtherObject
      attr_accessor :value
    end

    before do
      @value = 'value'
      @other = OtherObject.new
      @other.value = @value
      @doc = BSONTest.new(:other => @other)
    end

    it "encodes the class for the object" do
      @doc.to_bson[MongoDoc::BSON::CLASS_KEY].should == BSONTest.name
    end

    it "renders a json representation of the object" do
      @doc.to_bson.should be_bson_eql({MongoDoc::BSON::CLASS_KEY => BSONTest.name, "other" => {MongoDoc::BSON::CLASS_KEY => OtherObject.name, "value" => @value}})
    end

    it "includes the _id of the object" do
      @doc._id = Mongo::ObjectID.new
      @doc.to_bson.should be_bson_eql({MongoDoc::BSON::CLASS_KEY => BSONTest.name, "_id" => @doc._id.to_bson, "other" => {MongoDoc::BSON::CLASS_KEY => OtherObject.name, "value" => @value}})
    end

    it "roundtrips the object" do
      MongoDoc::BSON.decode(@doc.to_bson).should be_kind_of(BSONTest)
    end

    it "ignores the class hash when the :raw_json option is used" do
      MongoDoc::BSON.decode(@doc.to_bson.except(MongoDoc::BSON::CLASS_KEY), :raw_json => true)['other'].should == @other.to_bson
    end

    it "allows for derived classes" do
      derived = BSONDerived.new(:other => @other, :derived => 'derived')
      MongoDoc::BSON.decode(derived.to_bson).other.should be_kind_of(OtherObject)
    end

    it "roundtrips embedded ruby objects" do
      MongoDoc::BSON.decode(@doc.to_bson).other.should be_kind_of(OtherObject)
    end

    context "associations" do
      context "embed" do
        class TestEmbedBsonDoc
          include MongoDoc::Document

          embed :subdoc
        end

        class SubEmbedBsonDoc
          include MongoDoc::Document

          attr_accessor :attr
        end

        it "#to_bson renders a bson representation of the document" do
          doc = TestEmbedBsonDoc.new
          subdoc = SubEmbedBsonDoc.new(:attr => "value")
          bson = doc.to_bson
          bson["subdoc"] = subdoc.to_bson
          doc.subdoc = subdoc
          doc.to_bson.should == bson
        end

        it "roundtrips" do
          doc = TestEmbedBsonDoc.new
          subdoc = SubEmbedBsonDoc.new(:attr => "value")
          doc.subdoc = subdoc
          MongoDoc::BSON.decode(doc.to_bson).should == doc
        end
      end

      context "embed_many" do

        class SubEmbedManyBsonDoc
          include MongoDoc::Document

          attr_accessor :attr
        end

        class TestEmbedManyBsonDoc
          include MongoDoc::Document
          embed_many :subdoc, :class_name => 'SubEmbedManyBsonDoc'
        end

        it "#to_bson renders a bson representation of the document" do
          doc = TestEmbedManyBsonDoc.new
          subdoc = SubEmbedManyBsonDoc.new(:attr => "value")
          bson = doc.to_bson
          bson["subdoc"] = [subdoc].to_bson
          doc.subdoc = subdoc
          doc.to_bson.should == bson
        end

        it "roundtrips" do
          doc = TestEmbedManyBsonDoc.new
          subdoc = SubEmbedManyBsonDoc.new(:attr => "value")
          doc.subdoc = subdoc
          MongoDoc::BSON.decode(doc.to_bson).should == doc
        end

        it "roundtrips the proxy" do
          doc = TestEmbedManyBsonDoc.new(:subdoc => SubEmbedManyBsonDoc.new(:attr => "value"))
          MongoDoc::Associations::CollectionProxy.should === MongoDoc::BSON.decode(doc.to_bson).subdoc
        end
      end
    end
  end

  context "removing documents" do
    class RemoveDocument
      include MongoDoc::Document
    end

    let(:doc) { RemoveDocument.new }

    context "#remove" do
      it "when called on a embedded document with a _root raises UnsupportedOperation" do
        doc._root = RemoveDocument.new
        expect { doc.remove }.to raise_error(MongoDoc::UnsupportedOperation)
      end

      it "delegates to remove document" do
        doc.should_receive(:remove_document)
        doc.remove
      end
    end

    context "#remove_document" do
      it "when the document is the root, removes the document" do
        doc.should_receive(:_remove)
        doc.remove_document
      end

      it "when the document is not the root, calls remove_document on the root" do
        doc._root = root = RemoveDocument.new
        root.should_receive(:remove_document)
        doc.remove_document
      end
    end
  end

  context "misc class methods" do
    class ClassMethods
      include MongoDoc::Document
    end

    it ".collection_name returns the name of the collection for this class" do
      ClassMethods.collection_name.should == ClassMethods.to_s.tableize.gsub('/', '.')
    end

    it ".collection returns a wrapped MongoDoc::Collection" do
      db = stub('db')
      db.should_receive(:collection).with(ClassMethods.to_s.tableize.gsub('/', '.'))
      MongoDoc::Connection.should_receive(:database).and_return(db)
      MongoDoc::Collection.should === ClassMethods.collection
    end
  end
end
