require 'spec_helper'

describe "MongoDoc::Attributes" do
  class AttributesTest
    include MongoDoc::Attributes
  end

  it "defines _id attribute" do
    AttributesTest.new.should respond_to(:_id)
    AttributesTest.new.should respond_to(:_id=)
  end

  context ".key" do
    class TestKeys
      include MongoDoc::Attributes
      key :attr1, :attr2
    end

    it "adds its arguments to _keys" do
      TestKeys._keys.should == [:attr1, :attr2]
    end

    describe "accessors" do
      subject do
        TestKeys.new
      end

      it "has an attr1 reader" do
        should respond_to(:attr1)
      end

      it "has an attr1 writer" do
        should respond_to(:attr1=)
      end
    end

    context "default values" do
      class TestDefault
        include MongoDoc::Attributes
        key :with_default, :default => 'value'
      end

      let(:object) { TestDefault.new }

      it "uses the default value" do
        object.with_default.should == 'value'
      end

      it "only uses the default value once" do
        object.with_default.should == 'value'
        class << object
          def _default_with_default
            'other value'
          end
        end
        object.with_default.should == 'value'
      end

      it "does not set the default value if the setter is invoked first" do
        object.with_default = nil
        object.with_default.should be_nil
      end
    end

    describe "used with inheritance" do
      class TestParent
        include MongoDoc::Attributes

        key :parent_attr
      end

      class TestChild < TestParent
        key :child_attr
      end

      it "has its own keys" do
        TestChild._keys.should include(:child_attr)
      end

      it "has the keys from the parent class" do
        TestChild._keys.should include(*TestParent._keys)
      end

      it "does not add keys to the parent class" do
        TestParent._keys.should_not include(:child_attr)
      end
    end
  end

  context ".has_one" do
    class TestDoc
      include MongoDoc::Document

      has_one :sub_doc
    end

    class SubDoc
      include MongoDoc::Document

      key :data
    end

    let(:subdoc) { SubDoc.new }
    let(:doc) { TestDoc.new(:sub_doc => subdoc) }

    it "uses a proxy" do
      MongoDoc::Associations::DocumentProxy.should === doc.sub_doc
    end

    it "sets the subdocuments parent to the proxy" do
      doc.sub_doc.should == subdoc._parent
    end

    it "set the subdocuments root" do
      doc.should == subdoc._root
    end

    context "validations" do
      class HasOneValidationTest
        include MongoDoc::Document

        key :data
        validates_presence_of :data
      end

      it "cascades validations down" do
        invalid = HasOneValidationTest.new
        TestDoc.new(:sub_doc => invalid).should have(1).error_on(:sub_doc)
      end
    end
  end

  context "._attributes" do
    class TestHasOneDoc
      include MongoDoc::Document

      key :key
      has_one :has_one
    end

    it "is _keys + _associations" do
      TestHasOneDoc._attributes.should == TestHasOneDoc._keys + TestHasOneDoc._associations
    end
  end

  context ".has_many" do

    class SubHasManyDoc
      include MongoDoc::Document

      key :data
    end

    class TestHasManyDoc
      include MongoDoc::Document

      has_many :sub_docs, :class_name => 'SubHasManyDoc'
    end

    class TestHasManyDoc2
      include MongoDoc::Document

      has_many :sub_docs, :class_name => :sub_has_many_doc
    end

    class TestImplicitHasManyDoc
      include MongoDoc::Document

      has_many :sub_has_many_docs
    end

    let(:subdoc) { SubHasManyDoc.new }
    let(:doc) { TestHasManyDoc.new(:sub_docs => [subdoc]) }

    it "uses a proxy" do
      MongoDoc::Associations::CollectionProxy.should === TestHasManyDoc.new.sub_docs
    end

    it "sets the subdocuments parent to the proxy" do
      doc.sub_docs.should == subdoc._parent
    end

    it "set the subdocuments root to the root" do
      doc.should == subdoc._root
    end

    it "uses the association name to find the children's class name" do
      TestImplicitHasManyDoc.new.sub_has_many_docs.assoc_class.should == SubHasManyDoc
    end

    it "uses class_name attribute for the children's class name" do
      TestHasManyDoc.new.sub_docs.assoc_class.should == SubHasManyDoc
    end

    it "uses class_name attribute for the children's class name" do
      TestHasManyDoc2.new.sub_docs.assoc_class.should == SubHasManyDoc
    end

    context "validations" do
      class HasManyValidationChild
        include MongoDoc::Document

        key :data
        validates_presence_of :data
      end

      class HasManyValidationTest
        include MongoDoc::Document

        has_many :subdocs, :class_name => 'HasManyValidationChild'
      end

      let(:invalid_child) { HasManyValidationChild.new }
      let(:doc) { HasManyValidationTest.new(:subdocs => [invalid_child]) }

      it "cascades validations and marks it in the parent" do
        doc.should have(1).error_on(:subdocs)
      end

      it "cascades validations and marks it in the child" do
        invalid_child.should have(1).error_on(:data)
      end

      it "ignores non-document children" do
        HasManyValidationTest.new(:subdocs => ['not a doc']).should be_valid
      end
    end
  end

  context ".has_hash" do
    class SubHasHashDoc
      include MongoDoc::Document

      key :data
    end

    class TestHasHashDoc
      include MongoDoc::Document

      has_hash :sub_docs, :class_name => 'SubHasHashDoc'
    end

    class TestImplicitHasHashDoc
      include MongoDoc::Document

      has_hash :sub_has_hash_docs
    end

    let(:subdoc) { SubHasHashDoc.new }
    let(:doc) { TestHasHashDoc.new(:sub_docs => {:key => subdoc}) }

    it "uses a proxy" do
      MongoDoc::Associations::HashProxy.should === TestHasHashDoc.new.sub_docs
    end

    it "sets the subdocuments parent to the proxy" do
      doc.sub_docs.should == subdoc._parent
    end

    it "set the subdocuments root to the root" do
      doc.should == subdoc._root
    end

    it "uses the association name to find the children's class name" do
      TestImplicitHasHashDoc.new.sub_has_hash_docs.assoc_class.should == SubHasHashDoc
    end

    context "validations" do
      class HasHashValidationChild
        include MongoDoc::Document

        key :data
        validates_presence_of :data
      end

      class HasHashValidationTest
        include MongoDoc::Document

        has_hash :subdocs, :class_name => 'HasHashValidationChild'
      end

      let(:invalid_child) { HasHashValidationChild.new }
      let(:doc) { HasHashValidationTest.new(:subdocs => {:key => invalid_child}) }

      it "cascades validations and marks it in the parent" do
        doc.should have(1).error_on(:subdocs)
      end

      it "cascades validations and marks it in the child" do
        invalid_child.should have(1).error_on(:data)
      end

      it "ignores non-document children" do
        HasHashValidationTest.new(:subdocs => {:key => 'data'}).should be_valid
      end
    end
  end
end
