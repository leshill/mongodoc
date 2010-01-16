require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper.rb"))

describe MongoDoc::NamedScope do

  module Extension
    def extension_module_method
      "extension module method"
    end
  end

  class NamedScopeTest
    include MongoDoc::Document

    key :active
    key :count

    named_scope :active, :where => {:active => true} do
      def extension_method
        "extension method"
      end
    end
    named_scope :count_gt_one, :where => {:count => {'$gt' => 1}}, :extend => Extension
    named_scope :at_least_count, lambda {|count| {:where => {:count => {'$gt' => count}}}}
  end

  context ".named_scope" do
    it "adds the named scope to the hash of scopes" do
      NamedScopeTest.scopes.should have_key(:active)
    end

    it "creates a class method for the named scope" do
      NamedScopeTest.should respond_to(:active)
    end
  end

  context "accessing a named scope" do
    it "is a criteria proxy" do
      MongoDoc::NamedScope::CriteriaProxy.should === NamedScopeTest.active
    end

    it "responds like a criteria" do
      NamedScopeTest.active.should respond_to(:selector)
    end

    it "instantiates the criteria" do
      criteria = MongoDoc::Criteria.new(NamedScopeTest)
      MongoDoc::Criteria.should_receive(:new).and_return(criteria)
      NamedScopeTest.active.selector
    end

    it "has set the conditions on the criteria" do
      NamedScopeTest.active.selector.should has_entry(:active => true)
    end

    it "sets the association extension by block" do
      NamedScopeTest.active.extension_method.should == "extension method"
    end

    it "sets the association extension by :extend" do
      NamedScopeTest.count_gt_one.extension_module_method.should == "extension module method"
    end

    context "when using a lambda" do
      it "accepts parameters to the criteria" do
        NamedScopeTest.at_least_count(3).selector.should has_entry(:count => {'$gt' => 3})
      end
    end
  end

  context "chained scopes" do
    it "instantiates the criteria" do
      criteria = MongoDoc::Criteria.new(NamedScopeTest)
      MongoDoc::Criteria.should_receive(:new).and_return(criteria)
      NamedScopeTest.active.count_gt_one.selector
    end

    it "merges the criteria" do
      NamedScopeTest.active.count_gt_one.selector.should has_entry(:count => {'$gt' => 1}, :active => true)
    end
  end
end

