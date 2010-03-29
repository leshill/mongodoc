require 'spec_helper'

describe "MongoDoc::DocumentTree" do
  class DocumentTreeTest
    include MongoDoc::DocumentTree
    attr_accessor_with_default(:_associations) {[]}
    attr_accessor :association
  end

  let(:doc) { DocumentTreeTest.new }

  context "cascade properties" do
    let(:prop_val) { stub }

    %w(_modifier_path _root _selector_path).each do |prop|
      it "sets the #{prop}" do
        doc.send("#{prop}=", prop_val)
        doc.send(prop).should == prop_val
      end

      it "sets the prop on any associations" do
        doc.association = stub
        doc.association.should_receive("#{prop}=").with(prop_val)
        doc._associations = ['association']
        doc.send("#{prop}=", prop_val)
      end
    end
  end

  describe "#_selector_path" do
    it "defaults to ''" do
      doc._selector_path.should == ''
    end
  end

  describe "#_modifier_path" do
    it "defaults to ''" do
      doc._modifier_path.should == ''
    end
  end
end
