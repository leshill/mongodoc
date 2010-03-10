require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoDoc::Document" do

  context "satisfies form_for requirements" do
    class FormForTest
      include MongoDoc::Document

      key :data
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

      key :data
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

      has_many :save_children
    end

    class SaveChild
      include MongoDoc::Document

      key :data
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

      key :data
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
    class UpdateAttributesRoot
      include MongoDoc::Document

      has_one :update_attributes_child
    end

    class UpdateAttributesChild
      include MongoDoc::Document

      key :data
    end

    let(:data) {'data'}

    let(:attrs) {{:data => data}}

    let(:path_attrs) {{'update_attributes_child.data' => data}}

    let(:doc) do
      doc = UpdateAttributesChild.new
      doc._id = 'id'
      doc.stub(:_naive_update_attributes)
      doc
    end

    before do
      root = UpdateAttributesRoot.new
      root.update_attributes_child = doc
      root._id = 'id'
    end

    context "#update_attributes" do
      it "delegates to save if the object is a new record" do
        check = 'check'
        doc.stub(:new_record?).and_return(true)
        doc.should_receive(:save).and_return(check)
        doc.update_attributes(attrs).should == check
      end

      it "sets the attributes" do
        doc.update_attributes(attrs)
        doc.data.should == data
      end

      it "normalizes the attributes to the parent" do
        doc.should_receive(:_path_to_root)
        doc.update_attributes(attrs)
      end

      it "validates" do
        doc.should_receive(:valid?)
        doc.update_attributes(attrs)
      end

      it "returns false if the object is not valid" do
        doc.stub(:valid?).and_return(false)
        doc.update_attributes(attrs).should be_false
      end

      context "if valid" do
        context "and strict" do
          it "delegates to _strict_update_attributes" do
            strict_attrs = attrs.merge(:__strict__ => true)
            doc.should_receive(:_strict_update_attributes).with(path_attrs, false)
            doc.update_attributes(strict_attrs)
          end
        end

        context "and naive" do
          it "delegates to _naive_update_attributes" do
            doc.should_receive(:_naive_update_attributes).with(path_attrs, false)
            doc.update_attributes(attrs)
          end
        end

        it "returns the result of _naive_update_attributes" do
          result = 'check'
          doc.stub(:_naive_update_attributes).and_return(result)
          doc.update_attributes(attrs).should == result
        end
      end
    end

    context "#update_attributes!" do
      it "delegates to save! if the object is a new record" do
        check = 'check'
        doc.stub(:new_record?).and_return(true)
        doc.should_receive(:save!).and_return(check)
        doc.update_attributes!(attrs).should == check
      end

      it "sets the attributes" do
        doc.update_attributes!(attrs)
        doc.data.should == data
      end

      it "normalizes the attributes to the parent" do
        doc.should_receive(:_path_to_root)
        doc.update_attributes!(attrs)
      end

      it "validates" do
        doc.should_receive(:valid?).and_return(true)
        doc.update_attributes!(attrs)
      end

      it "raises if not valid" do
        doc.stub(:valid?).and_return(false)
        expect do
          doc.update_attributes!(attrs)
        end.should raise_error(MongoDoc::DocumentInvalidError)
      end

      context "if valid" do
        context "and strict" do
          it "delegates to _strict_update_attributes with safe == true" do
            strict_attrs = attrs.merge(:__strict__ => true)
            doc.should_receive(:_strict_update_attributes).with(path_attrs, true)
            doc.update_attributes!(strict_attrs)
          end
        end

        context "and naive" do
          it "delegates to _naive_update_attributes with safe == true" do
            doc.should_receive(:_naive_update_attributes).with(path_attrs, true)
            doc.update_attributes!(attrs)
          end
        end

        it "returns the result of _naive_update_attributes" do
          result = 'check'
          doc.stub(:_naive_update_attributes).and_return(result)
          doc.update_attributes!(attrs).should == result
        end
      end
    end
  end

  context "#_naive_update_attributes" do
    class NaiveUpdateAttributes
      include MongoDoc::Document
    end


    let(:id) { 'id' }

    let(:attrs) { {:data => 'data'} }

    let(:safe) { false }

    let(:doc) do
      doc = NaiveUpdateAttributes.new
      doc.stub(:_id).and_return(id)
      doc
    end

    it "without a root delegates to _update" do
      doc.should_receive(:_update).with({}, attrs, safe)
      doc.send(:_naive_update_attributes, attrs, safe)
    end

    it "with a root, calls _naive_update_attributes on the root" do
      root = NaiveUpdateAttributes.new
      doc.stub(:_root).and_return(root)
      root.should_receive(:_naive_update_attributes).with(attrs, safe)
      doc.send(:_naive_update_attributes, attrs, safe)
    end
  end

  context "#_strict_update_attributes" do
    class StrictUpdateAttributes
      include MongoDoc::Document
    end

    let(:id) { 'id' }

    let(:attrs) { {:data => 'data'} }

    let(:selector) { {:selector => 'selector'} }

    let(:safe) { false }

    let(:doc) do
      doc = StrictUpdateAttributes.new
      doc.stub(:_id).and_return(id)
      doc
    end

    context "without a root" do
      it "without a root delegates to _update" do
        doc.should_receive(:_update).with(selector, attrs, safe)
        doc.send(:_strict_update_attributes, attrs, safe, selector)
      end
    end

    context "with a root" do
      let(:root) { StrictUpdateAttributes.new }

      before do
        doc.stub(:_root).and_return(root)
      end

      it "calls _path_to_root on our id" do
        root.stub(:_strict_update_attributes)
        doc.should_receive(:_path_to_root).with(doc, '_id' => id)
        doc.send(:_strict_update_attributes, attrs, safe)
      end

      it "calls _strict_update_attributes on the root with our selector" do
        selector = {'path._id' => id}
        doc.stub(:_path_to_root).with(doc, '_id' => id).and_return(selector)
        root.should_receive(:_strict_update_attributes).with(attrs, safe, selector)
        doc.send(:_strict_update_attributes, attrs, safe)
      end
    end
  end

  describe "bson" do
    class BSONTest
      include MongoDoc::Document

      key :other
    end

    class BSONDerived < BSONTest
      include MongoDoc::Document

      key :derived
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
      context "has_one" do
        class TestHasOneBsonDoc
          include MongoDoc::Document

          has_one :subdoc
        end

        class SubHasOneBsonDoc
          include MongoDoc::Document

          key :attr
        end

        it "#to_bson renders a bson representation of the document" do
          doc = TestHasOneBsonDoc.new
          subdoc = SubHasOneBsonDoc.new(:attr => "value")
          bson = doc.to_bson
          bson["subdoc"] = subdoc.to_bson
          doc.subdoc = subdoc
          doc.to_bson.should == bson
        end

        it "roundtrips" do
          doc = TestHasOneBsonDoc.new
          subdoc = SubHasOneBsonDoc.new(:attr => "value")
          doc.subdoc = subdoc
          MongoDoc::BSON.decode(doc.to_bson).should == doc
        end
      end

      context "has_many" do

        class SubHasManyBsonDoc
          include MongoDoc::Document

          key :attr
        end

        class TestHasManyBsonDoc
          include MongoDoc::Document
          has_many :subdoc, :class_name => 'SubHasManyBsonDoc'
        end

        it "#to_bson renders a bson representation of the document" do
          doc = TestHasManyBsonDoc.new
          subdoc = SubHasManyBsonDoc.new(:attr => "value")
          bson = doc.to_bson
          bson["subdoc"] = [subdoc].to_bson
          doc.subdoc = subdoc
          doc.to_bson.should == bson
        end

        it "roundtrips" do
          doc = TestHasManyBsonDoc.new
          subdoc = SubHasManyBsonDoc.new(:attr => "value")
          doc.subdoc = subdoc
          MongoDoc::BSON.decode(doc.to_bson).should == doc
        end

        it "roundtrips the proxy" do
          doc = TestHasManyBsonDoc.new(:subdoc => SubHasManyBsonDoc.new(:attr => "value"))
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
