require 'spec_helper'

describe "MongoDoc::Associations" do

  context ".embed" do
    class TestDoc
      include MongoDoc::Document

      embed :sub_doc
    end

    class SubDoc
      include MongoDoc::Document

      attr_accessor :data
    end

    class TestHasOne
      include MongoDoc::Document

      has_one :sub_doc
    end

    let(:subdoc) { SubDoc.new }
    let(:doc) { TestDoc.new(:sub_doc => subdoc) }

    it "uses a proxy" do
      MongoDoc::Associations::DocumentProxy.should === doc.sub_doc
    end

    it ".has_one is an alias for embed" do
      MongoDoc::Associations::DocumentProxy.should === TestHasOne.new(:sub_doc => SubDoc.new).sub_doc
    end

    it "sets the subdocuments parent to the proxy" do
      doc.sub_doc.should == subdoc._parent
    end

    it "set the subdocuments root" do
      doc.should == subdoc._root
    end

    context "validations" do
      class EmbedValidationTest
        include MongoDoc::Document

        attr_accessor :data
        validates_presence_of :data
      end

      it "cascades validations down" do
        invalid = EmbedValidationTest.new
        TestDoc.new(:sub_doc => invalid).should have(1).error_on(:sub_doc)
      end
    end
  end

  context ".embed_many" do

    class SubEmbedManyDoc
      include MongoDoc::Document

      attr_accessor :data
    end

    class TestEmbedManyDoc
      include MongoDoc::Document

      embed_many :sub_docs, :class_name => 'SubEmbedManyDoc'
    end

    class TestEmbedManyDoc2
      include MongoDoc::Document

      embed_many :sub_docs, :class_name => :sub_embed_many_doc
    end

    class TestImplicitEmbedManyDoc
      include MongoDoc::Document

      embed_many :sub_embed_many_docs
    end

    class TestHasManyDoc
      include MongoDoc::Document

      has_many :sub_docs, :class_name => 'SubEmbedManyDoc'
    end

    let(:subdoc) { SubEmbedManyDoc.new }
    let(:doc) { TestEmbedManyDoc.new(:sub_docs => [subdoc]) }

    it "uses a proxy" do
      MongoDoc::Associations::CollectionProxy.should === TestEmbedManyDoc.new.sub_docs
    end

    it ".has_many is an alias for .embed_many" do
      MongoDoc::Associations::CollectionProxy.should === TestHasManyDoc.new.sub_docs
    end

    it "sets the subdocuments parent to the proxy" do
      doc.sub_docs.should == subdoc._parent
    end

    it "set the subdocuments root to the root" do
      doc.should == subdoc._root
    end

    it "uses the association name to find the children's class name" do
      TestImplicitEmbedManyDoc.new.sub_embed_many_docs.assoc_class.should == SubEmbedManyDoc
    end

    it "uses class_name attribute for the children's class name" do
      TestEmbedManyDoc.new.sub_docs.assoc_class.should == SubEmbedManyDoc
    end

    it "uses class_name attribute for the children's class name" do
      TestEmbedManyDoc2.new.sub_docs.assoc_class.should == SubEmbedManyDoc
    end

    context "validations" do
      class EmbedManyValidationChild
        include MongoDoc::Document

        attr_accessor :data
        validates_presence_of :data
      end

      class EmbedManyValidationTest
        include MongoDoc::Document

        embed_many :subdocs, :class_name => 'HasManyValidationChild'
      end

      let(:invalid_child) { EmbedManyValidationChild.new }
      let(:doc) { EmbedManyValidationTest.new(:subdocs => [invalid_child]) }

      it "cascades validations and marks it in the parent" do
        doc.should have(1).error_on(:subdocs)
      end

      it "cascades validations and marks it in the child" do
        invalid_child.should have(1).error_on(:data)
      end

      it "ignores non-document children" do
        EmbedManyValidationTest.new(:subdocs => ['not a doc']).should be_valid
      end
    end
  end

  context ".embed_hash" do
    class SubEmbedHashDoc
      include MongoDoc::Document

      attr_accessor :data
    end

    class TestEmbedHashDoc
      include MongoDoc::Document

      embed_hash :sub_docs, :class_name => 'SubEmbedHashDoc'
    end

    class TestImplicitEmbedHashDoc
      include MongoDoc::Document

      embed_hash :sub_embed_hash_docs
    end

    class TestHasHashDoc
      include MongoDoc::Document

      has_hash :sub_embed_hash_docs
    end

    let(:subdoc) { SubEmbedHashDoc.new }
    let(:doc) { TestEmbedHashDoc.new(:sub_docs => {:key => subdoc}) }

    it "uses a proxy" do
      MongoDoc::Associations::HashProxy.should === TestEmbedHashDoc.new.sub_docs
    end

    it ".has_hash is an alias for embed_hash" do
      MongoDoc::Associations::HashProxy.should === TestEmbedHashDoc.new.sub_docs
    end

    it "sets the subdocuments parent to the proxy" do
      doc.sub_docs.should == subdoc._parent
    end

    it "set the subdocuments root to the root" do
      doc.should == subdoc._root
    end

    it "uses the association name to find the children's class name" do
      TestImplicitEmbedHashDoc.new.sub_embed_hash_docs.assoc_class.should == SubEmbedHashDoc
    end

    context "validations" do
      class EmbedHashValidationChild
        include MongoDoc::Document

        attr_accessor :data
        validates_presence_of :data
      end

      class EmbedHashValidationTest
        include MongoDoc::Document

        has_hash :subdocs, :class_name => 'EmbedHashValidationChild'
      end

      let(:invalid_child) { EmbedHashValidationChild.new }
      let(:doc) { EmbedHashValidationTest.new(:subdocs => {:key => invalid_child}) }

      it "cascades validations and marks it in the parent" do
        doc.should have(1).error_on(:subdocs)
      end

      it "cascades validations and marks it in the child" do
        invalid_child.should have(1).error_on(:data)
      end

      it "ignores non-document children" do
        EmbedHashValidationTest.new(:subdocs => {:key => 'data'}).should be_valid
      end
    end
  end
end
