require 'spec_helper'

describe "Saving embedded documents" do
  class NestedDocsRoot
    include MongoDoc::Document

    embed_many :nested_children
  end

  class NestedChild
    include MongoDoc::Document

    embed :leaf
  end

  class LeafDoc
    include MongoDoc::Document

    attr_accessor :data
  end

  let(:leaf) do
    doc = LeafDoc.new
    doc._id = 'id'
    doc
  end

  let(:data) { 'data' }

  context "#save" do
    let(:root) { NestedDocsRoot.new(:nested_children => [NestedChild.new(:leaf => leaf)]) }

    it "calls the root document's save" do
      root.should_receive(:save).with(true)
      leaf.save
    end

    it "(with bang!) calls the root documents save!" do
      root.should_receive(:save!)
      leaf.save!
    end
  end

  context "update_attributes" do
    context "with no embed_many, update_attributes" do
      let(:root) { NestedChild.new(:leaf => leaf) }

      it "calls the root document's _update with a full attribute path and not safe" do
        root.should_receive(:_update).with({"leaf._id"=>"id"}, {'leaf.data' => data}, false)
        leaf.update_attributes(:data => data)
      end

      it "(with bang!) calls the root document's _update with a full attribute path and safe" do
        root.should_receive(:_update).with({"leaf._id"=>"id"}, {'leaf.data' => data}, true)
        leaf.update_attributes!(:data => data)
      end
    end

    context "with embed_many, update_attributes" do
      let(:root) { NestedDocsRoot.new(:nested_children => [NestedChild.new(:leaf => leaf)]) }

      it "calls the root document's _update with a full attribute path and not safe" do
        root.should_receive(:_update).with({"nested_children.leaf._id"=>"id"}, {'nested_children.$.leaf.data' => data}, false)
        leaf.update_attributes(:data => data)
      end

      it "(with bang!) calls the root document's _update with a full attribute path and safe" do
        root.should_receive(:_update).with({"nested_children.leaf._id"=>"id"}, {'nested_children.$.leaf.data' => data}, true)
        leaf.update_attributes!(:data => data)
      end
    end
  end
end
