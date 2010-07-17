require 'spec_helper'

describe MongoDoc::Criteria do

  class CriteriaTest
    extend MongoDoc::Criteria

    def self.collection; end
  end

  context ".criteria" do
    it "creates a new CriteriaWrapper for the document" do
      CriteriaTest.criteria.should be_a_kind_of(MongoDoc::Criteria::CriteriaWrapper)
    end
  end

  context "CriteriaWrapper" do
    let(:wrapper) { MongoDoc::Criteria::CriteriaWrapper.new(CriteriaTest) }

    it "is a Criteria" do
      Mongoid::Criteria.should === wrapper
    end

    it "sets the criteria klass" do
      wrapper.klass.should == CriteriaTest
    end

    %w(all and any_in cache enslave excludes fuse in limit offset only order_by skip where).each do |wrapping_method|
      it "#{wrapping_method} returns a new CriteriaWrapper" do
        wrapper.send(wrapping_method).object_id.should_not == wrapper.object_id
      end
    end

    it "extras returns a new CriteriaWrapper" do
      wrapper.extras({}).object_id.should_not == wrapper.object_id
    end

    it "not_in returns a new CriteriaWrapper" do
      wrapper.not_in({}).object_id.should_not == wrapper.object_id
    end

  end

  context "criteria delegates" do
    let(:criteria) { stub('criteria').as_null_object }

    before do
      CriteriaTest.stub(:criteria).and_return(criteria)
    end

    %w(aggregate all and any_in blank? count empty? excludes extras first group id in last limit max min not_in offset one only order_by page paginate per_page skip sum where).each do |criteria_op|
      it "#{criteria_op} delegates to the criteria" do
        criteria.should_receive(criteria_op)
        CriteriaTest.send(criteria_op)
      end
    end
  end

  context "criteria are reusable" do
    it "creates a new instance on each invocation" do
      original = CriteriaTest.any_in(:name => 'Les Hill')
      chained = original.only(:name)
      original.should_not == chained
    end
  end
end
