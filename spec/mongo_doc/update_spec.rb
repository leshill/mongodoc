require 'spec_helper'

describe "MongoDoc::Document" do

  class UpdateAttributesChild
    include MongoDoc::Document

    attr_accessor :child_data
    attr_accessor :child_int, :type => Integer
  end

  class UpdateAttributes
    include MongoDoc::Document

    attr_accessor :data
    attr_accessor :int, :type => Integer
    embed :child
  end

  let(:collection) { stub(:save => nil, :update => nil) }
  let(:child) do
    child = UpdateAttributesChild.new
    child._id = 'child exists'
    existing_doc.child = child
    child
  end
  let(:existing_doc) do
    doc = UpdateAttributes.new
    doc._id = 'exists'
    doc.stub(:_collection).and_return(collection)
    doc
  end
  let(:new_child) do
    child = UpdateAttributesChild.new
    existing_doc.child = child
    child
  end

  let(:new_doc) { UpdateAttributes.new }

  describe "#update" do
    context "with a new doc" do
      it "delegates to save! if the doc is a new record" do
        new_doc.should_receive(:_save)
        new_doc.update(:data => 'data', :int => '1')
      end

      it "delegates to the root's save if the child is a new record" do
        existing_doc.should_receive(:_save)
        new_child.update(:child_data => 'data', :child_int => '1')
      end
    end

    context "with an existing doc" do

      subject { existing_doc.update(:data => 'data', :int => '1') }

      it "sets the attributes" do
        subject
        existing_doc.data.should == 'data'
        existing_doc.int.should == 1
      end

      it "delegates to collection update" do
        collection.should_receive(:update).with({'_id' => existing_doc._id}, {'$set' => {:data => 'data', :int => 1}}, :safe => false)
        subject
      end

      context "that is embedded" do
        it "delegates to the root's collection update" do
          collection.should_receive(:update).with({'_id' => existing_doc._id, 'child._id' => child._id}, {'$set' => {'child.child_data' => 'data', 'child.child_int' => 1}}, :safe => true)
          child.update_attributes!(:child_data => 'data', :child_int => '1')
        end
      end
    end
  end

  describe "#update_attributes" do
    it "delegates to save if the doc is a new record" do
      new_doc.should_receive(:save)
      new_doc.update_attributes(:data => 'data', :int => '1')
    end

    context "with an existing doc" do

      subject { existing_doc.update_attributes(:data => 'data', :int => '1') }

      it "sets the attributes" do
        subject
        existing_doc.data.should == 'data'
        existing_doc.int.should == 1
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
        collection.should_receive(:update).with({'_id' => existing_doc._id}, {'$set' => {:data => 'data', :int => 1}}, :safe => false)
        subject
      end

      context "that is embedded" do
        it "delegates to the root's collection update" do
          collection.should_receive(:update).with({'_id' => existing_doc._id, 'child._id' => child._id}, {'$set' => {'child.child_data' => 'data', 'child.child_int' => 1}}, :safe => false)
          child.update_attributes(:child_data => 'data', :child_int => '1')
        end
      end
    end
  end

  describe "#update_attributes!" do
    it "delegates to save! if the doc is a new record" do
      new_doc.should_receive(:save!)
      new_doc.update_attributes!(:data => 'data', :int => '1')
    end

    context "with an existing doc" do

      subject { existing_doc.update_attributes!(:data => 'data', :int => '1') }

      it "sets the attributes" do
        subject
        existing_doc.data.should == 'data'
        existing_doc.int.should == 1
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
        collection.should_receive(:update).with({'_id' => existing_doc._id}, {'$set' => {:data => 'data', :int => 1}}, :safe => true)
        subject
      end

      context "that is embedded" do
        it "delegates to the root's collection update" do
          collection.should_receive(:update).with({'_id' => existing_doc._id, 'child._id' => child._id}, {'$set' => {'child.child_data' => 'data', 'child.child_int' => 1}}, :safe => true)
          child.update_attributes!(:child_data => 'data', :child_int => '1')
        end
      end
    end
  end

  describe "#hash_with_modifier_path_keys" do
    it "returns a hash with the keys prepended with the modifier path" do
      new_doc.stub(:_modifier_path).and_return('path.to.root')
      new_doc.send(:hash_with_modifier_path_keys, :name => 1).should == {'path.to.root.name' => 1}
    end
  end

end
