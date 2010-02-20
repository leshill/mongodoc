require 'spec_helper'

describe MongoDoc::Criteria do

  class CriteriaTest
    extend MongoDoc::Criteria
  end

  context ".criteria" do
    it "creates a new criteria for the document" do
      CriteriaTest.criteria.should be_a_kind_of(Mongoid::Criteria)
    end

    it "sets the criteria klass" do
      CriteriaTest.criteria.klass.should == CriteriaTest
    end
  end

  context "criteria delegates" do
    let(:criteria) { stub('criteria').as_null_object }

    before do
      CriteriaTest.stub(:criteria).and_return(criteria)
    end

    %w(and cache enslave excludes extras id in limit not_in offset only order_by page per_page skip where).each do |criteria_op|
      it "#{criteria_op} delegates to the criteria" do
        criteria.should_receive(criteria_op)
        CriteriaTest.send(criteria_op)
      end
    end
  end
end
