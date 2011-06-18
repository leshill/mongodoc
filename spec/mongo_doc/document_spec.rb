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

  context "ActiveModel" do
    class FormForTest
      include MongoDoc::Document

      attr_accessor :data
    end

    describe FormForTest do
      it_should_behave_like AnActiveModel
    end

    let(:doc) { FormForTest.new }

    context "persisted record" do
      subject { doc._id = '1'; doc }

      it { should_not be_new_record }
      it { should be_persisted }
      its(:id) { should == doc._id }
      its(:to_param) { should == doc._id.to_s }
      its(:to_key) { should == [doc._id] }
    end

    context "record has not been persisted" do
      subject { doc }

      it { should be_new_record }
      it { should_not be_persisted }
      its(:id) { should be_nil }
      its(:to_param) { should be_nil }
      its(:to_key) { should be_nil }
    end

    it "#initialize takes a hash" do
      data = 'data'
      FormForTest.new(:data => data).data.should == data
    end

    it "#initialize accepts a nil" do
      expect do
        FormForTest.new(nil)
      end.should_not raise_error
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
      @doc._id = BSON::ObjectId.new
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
    class MiscClassMethods
      include MongoDoc::Document
    end

    it ".collection_name returns the name of the collection for this class" do
      MiscClassMethods.collection_name.should == MiscClassMethods.to_s.tableize.gsub('/', '.')
    end

    it ".collection returns a wrapped MongoDoc::Collection" do
      db = stub('db')
      db.should_receive(:collection).with(MiscClassMethods.to_s.tableize.gsub('/', '.'))
      MongoDoc::Connection.should_receive(:database).and_return(db)
      MongoDoc::Collection.should === MiscClassMethods.collection
    end
  end

  context "ActiveModel compliance" do
    class ActiveModelComplianceTest
      include MongoDoc::Document
    end

    let(:model) { ActiveModelComplianceTest.new }

    describe "#to_param" do
      let(:string_id) { mock }

      before(:each) do
        model.instance_variable_set(:@_id, mock(:oid, :to_s => string_id))
      end

      it "returns the string form of the document id" do
        model.to_param.should == string_id
      end
    end

    describe "#valid?" do
      subject { model }
      it "responds to #valid?" do
        should respond_to(:valid?)
      end
    end

    describe "#new_record?" do
      subject { model }
      it "responds to #new_record?" do
        should respond_to(:new_record?)
      end

      context "when the object has an id" do
        before(:each) do
          model.instance_variable_set(:@_id, mock(:id))
        end

        it "is false" do
          should_not be_new_record
        end
      end

      context "when the object has no id" do
        before(:each) do
          model.instance_variable_set(:@_id, nil)
        end

        it "is true" do
          should be_new_record
        end
      end
    end

    describe "#destroyed?" do
      subject { model }

      it "responds to #destroyed?" do
        should respond_to(:destroyed?)
      end

      context "when the object has an id" do
        before(:each) do
          model.instance_variable_set(:@_id, mock(:id))
        end

        it "is false" do
          should_not be_destroyed
        end
      end

      context "when the object has no id" do
        before(:each) do
          model.instance_variable_set(:@_id, nil)
        end

        it "is true" do
          should be_destroyed
        end
      end
    end

    describe "#errors" do
      subject { model }
      it "responds to errors" do
        should respond_to(:errors)
      end

      describe "#[]" do
        it "returns an array on a missing key lookup" do
          model.errors[:does_not_exist].should be_an(Array)
        end
      end

      describe "#full_messages" do
        it "returns an array" do
          model.errors.full_messages.should be_an(Array)
        end
      end
    end

    describe ".model_name" do
      it "responds to model_name" do
        ActiveModelComplianceTest.should respond_to(:model_name)
      end

      it "is a string" do
        ActiveModelComplianceTest.model_name.should be_a(String)
      end

      it "has a human inflector" do
        ActiveModelComplianceTest.model_name.human.should be_a(String)
      end

      it "has a partial path inflector" do
        ActiveModelComplianceTest.model_name.partial_path.should be_a(String)
      end

      it "has a singular inflector" do
        ActiveModelComplianceTest.model_name.singular.should be_a(String)
      end

      it "has a plural inflector" do
        ActiveModelComplianceTest.model_name.plural.should be_a(String)
      end
    end
  end
end
