require 'spec_helper'

describe "MongoDoc::Associations" do

  context ".has_one" do
    class TestDoc
      include MongoDoc::Document

      has_one :sub_doc
    end

    class SubDoc
      include MongoDoc::Document

      attr_accessor :data
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

        attr_accessor :data
        validates_presence_of :data
      end

      it "cascades validations down" do
        invalid = HasOneValidationTest.new
        TestDoc.new(:sub_doc => invalid).should have(1).error_on(:sub_doc)
      end
    end
  end

  context ".has_many" do

    class SubHasManyDoc
      include MongoDoc::Document

      attr_accessor :data
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

        attr_accessor :data
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

      attr_accessor :data
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

        attr_accessor :data
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
