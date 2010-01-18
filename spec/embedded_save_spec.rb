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

  let(:leaf) { LeafDoc.new }
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

  context "update_attributes naive" do
    context "with no has_many, update_attributes" do
      let(:root) { NestedChild.new(:leaf => leaf) }

      it "calls the root document's _naive_update_attributes with a full attribute path and not safe" do
        root.should_receive(:_naive_update_attributes).with({'leaf.data' => data}, false)
        leaf.update_attributes(:data => data)
      end

      it "(with bang!) calls the root document's _naive_update_attributes with a full attribute path and safe" do
        root.should_receive(:_naive_update_attributes).with({'leaf.data' => data}, true)
        leaf.update_attributes!(:data => data)
      end
    end

    context "with has_many, update_attributes" do
      let(:root) { NestedDocsRoot.new(:nested_children => [NestedChild.new(:leaf => leaf)]) }

      it "calls the root document's _naive_update_attributes with a full attribute path and not safe" do
        root.should_receive(:_naive_update_attributes).with({'nested_children.0.leaf.data' => data}, false)
        leaf.update_attributes(:data => data)
      end

      it "(with bang!) calls the root document's _naive_update_attributes with a full attribute path and safe" do
        root.should_receive(:_naive_update_attributes).with({'nested_children.0.leaf.data' => data}, true)
        leaf.update_attributes!(:data => data)
      end
    end
  end

  context "update_attributes strict" do
    let(:leaf_id) { 'leaf_id' }

    before do
      leaf.stub(:_id).and_return(leaf_id)
    end

    context "with no has_many, update_attributes" do
      let(:root) { NestedChild.new(:leaf => leaf) }

      it "calls the root document's _strict_update_attributes with a full attribute path and not safe" do
        root.should_receive(:_strict_update_attributes).with({'leaf.data' => data}, false, 'leaf._id' => leaf_id)
        leaf.update_attributes(:data => data, :__strict__ => true)
      end

      it "(with bang!) calls the root document's _naive_update_attributes with a full attribute path and safe" do
        root.should_receive(:_strict_update_attributes).with({'leaf.data' => data}, true, 'leaf._id' => leaf_id)
        leaf.update_attributes!(:data => data, :__strict__ => true)
      end
    end

    context "with has_many, update_attributes" do
      let(:root) { NestedDocsRoot.new(:nested_children => [NestedChild.new(:leaf => leaf)]) }

      it "calls the root document's _naive_update_attributes with a full attribute path and not safe" do
        root.should_receive(:_strict_update_attributes).with({'nested_children.0.leaf.data' => data}, false, 'nested_children.leaf._id' => leaf_id)
        leaf.update_attributes(:data => data, :__strict__ => true)
      end

      it "(with bang!) calls the root document's _naive_update_attributes with a full attribute path and safe" do
        root.should_receive(:_strict_update_attributes).with({'nested_children.0.leaf.data' => data}, true, 'nested_children.leaf._id' => leaf_id)
        leaf.update_attributes!(:data => data, :__strict__ => true)
      end
    end
  end
end
