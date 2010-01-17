require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Saving embedded documents" do
  class NestedDocsRoot
    include MongoDoc::Document

    has_many :nested_children
  end

  class NestedChild
    include MongoDoc::Document

    has_one :leaf
  end

  class LeafDoc
    include MongoDoc::Document

    key :data
  end

  context "#save" do
    before do
      @leaf = LeafDoc.new
      @root = NestedDocsRoot.new(:nested_children => [NestedChild.new(:leaf => @leaf)])
    end

    it "calls the root document's save" do
      @root.should_receive(:save).with(true)
      @leaf.save
    end

    it "(with bang!) calls the root documents save!" do
      @root.should_receive(:save!)
      @leaf.save!
    end
  end

  context "update_attributes naive" do
    context "with no has_many, update_attributes" do
      before do
        @leaf = LeafDoc.new
        @root = NestedChild.new(:leaf => @leaf)
      end

      it "calls the root document's _naive_update_attributes with a full attribute path and not safe" do
        @root.should_receive(:_naive_update_attributes).with({'leaf.data' => 'data'}, false)
        @leaf.update_attributes(:data => 'data')
      end

      it "(with bang!) calls the root document's _naive_update_attributes with a full attribute path and safe" do
        @root.should_receive(:_naive_update_attributes).with({'leaf.data' => 'data'}, true)
        @leaf.update_attributes!(:data => 'data')
      end
    end

    context "with has_many, update_attributes" do
      before do
        @leaf = LeafDoc.new
        @root = NestedDocsRoot.new(:nested_children => [NestedChild.new(:leaf => @leaf)])
      end

      it "calls the root document's _naive_update_attributes with a full attribute path and not safe" do
        @root.should_receive(:_naive_update_attributes).with({'nested_children.0.leaf.data' => 'data'}, false)
        @leaf.update_attributes(:data => 'data')
      end

      it "(with bang!) calls the root document's _naive_update_attributes with a full attribute path and safe" do
        @root.should_receive(:_naive_update_attributes).with({'nested_children.0.leaf.data' => 'data'}, true)
        @leaf.update_attributes!(:data => 'data')
      end
    end
  end
end
