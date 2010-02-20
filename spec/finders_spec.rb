require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper.rb"))

describe MongoDoc::Finders do
  class FindersTest
    include MongoDoc::Document

    key :data
  end

  let(:criteria) { stub('criteria').as_null_object }

  context ".find" do
    before do
      FindersTest.stub(:criteria).and_return(criteria)
    end

    it "delegates to id for the criteria" do
      args = [1, 2, 3]
      criteria.should_receive(:id).with(*args)
      FindersTest.find(*args)
    end
  end

  context ".find_one" do
    context "with an id" do
      it "delegates to translate" do
        id = 'an id'
        Mongoid::Criteria.should_receive(:translate).with(FindersTest, id)
        FindersTest.find_one(id)
      end
    end

    context "with conditions" do
      let(:conditions) { {:where => 'this.a > 3'} }

      it "calls translate with the conditions" do
        Mongoid::Criteria.should_receive(:translate).with(FindersTest, conditions).and_return(criteria)
        FindersTest.find_one(conditions)
      end

      it "call one on the result" do
        Mongoid::Criteria.stub(:translate).and_return(criteria)
        criteria.should_receive(:one)
        FindersTest.find_one(conditions)
      end
    end
  end

  context "all other finders" do
    before do
      FindersTest.stub(:criteria).and_return(criteria)
    end

    %w(all count first last).each do |which|
      it "calls #{which} on the new criteria" do
        criteria.should_receive(which)
        FindersTest.send(which)
      end
    end
  end
end
