require 'spec_helper'

describe "MongoDoc::DocumentTree" do
  class DocumentTreeTest
    include MongoDoc::DocumentTree
    attr_accessor_with_default(:_associations) {[]}
    attr_accessor :association
  end

  let(:doc) { DocumentTreeTest.new }

  describe "#_root=" do
    let(:root) { stub }

    it "sets the root" do
      doc._root = root
      doc._root.should == root
    end

    it "sets the root on any associations" do
      doc.association = stub
      doc.association.should_receive(:_root=)
      doc._associations = ['association']
      doc._root = root
    end
  end

  context "paths" do
    context "when there is no parent" do
      it "#_path_to_root returns ''" do
        doc._path_to_root.should == ''
      end

      it "_update_path_to_root returns ''" do
        doc._update_path_to_root.should == ''
      end
    end

    context "when there is a parent" do
      before do
        doc._parent = stub
      end

      it "#_path_to_root delegates to the parent" do
        doc._parent.should_receive(:_path_to_root)
        doc._path_to_root
      end

      it "#_update_path_to_root delegates to the parent" do
        doc._parent.should_receive(:_update_path_to_root)
        doc._update_path_to_root
      end
    end
  end
end
