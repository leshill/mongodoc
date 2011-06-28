require 'spec_helper'

describe MongoDoc::Scope do

  module Extension
    def extension_module_method
      "extension module method"
    end
  end

  class ScopeTest
    include MongoDoc::Document

    attr_accessor :active
    attr_accessor :count

    scope :active, where(:active => true)
    scope :count_lte_one, where(:count.lte => 1) do
      def extension_method
        "extension method"
      end
    end
    scope :count_gt_one, where(:count.gt => 1), :extend => Extension
    scope :at_least_count, lambda {|count| where(:count.gt => count)}
  end

  context ".scope" do
    it "adds the named scope to the hash of scopes" do
      ScopeTest.scopes.should have_key(:active)
    end

    it "creates a class method for the named scope" do
      ScopeTest.should respond_to(:active)
    end
  end

  context "accessing a named scope" do
    it "is a criteria proxy" do
      MongoDoc::Scope::CriteriaProxy.should === ScopeTest.active
    end

    it "responds like a criteria" do
      ScopeTest.active.should respond_to(:selector)
    end

    it "has set the conditions on the criteria" do
      ScopeTest.active.selector.should include(:active => true)
    end

    it "sets the association extension by block" do
      ScopeTest.count_lte_one.extension_method.should == "extension method"
    end

    it "sets the association extension by :extend" do
      ScopeTest.count_gt_one.extension_module_method.should == "extension module method"
    end

    context "when using a lambda" do
      it "accepts parameters to the criteria" do
        ScopeTest.at_least_count(3).selector.should include(:count => {'$gt' => 3})
      end
    end
  end

  context "chained scopes" do
    it "is a criteria proxy" do
      MongoDoc::Scope::CriteriaProxy.should === ScopeTest.active.count_gt_one
    end

    it "responds like a criteria" do
      ScopeTest.active.count_gt_one.should respond_to(:selector)
    end

    it "merges the criteria" do
      ScopeTest.active.count_gt_one.selector.should include(:count => {'$gt' => 1}, :active => true)
    end

    it "chains with other criteria" do
      ScopeTest.active.where(:count => 1).selector.should include(:count => 1, :active => true)
    end

    let(:id) { BSON::ObjectId.new }
    it "chains with id" do
      ScopeTest.active.id(id).selector.should include(:active => true, :_id => id)
    end
  end
end

