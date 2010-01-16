require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper.rb"))

describe MongoDoc::Finders do
  class FindersTest
    include MongoDoc::Document

    key :data
  end

  context ".criteria" do
    it "creates a new criteria for the document" do
      FindersTest.criteria.should be_a_kind_of(MongoDoc::Criteria)
    end

    it "sets the criteria klass" do
      FindersTest.criteria.klass.should == FindersTest
    end
  end

  context ".find" do
    before do
      @criteria = stub('criteria').as_null_object
      @conditions = {:where => 'this.a > 3'}
      MongoDoc::Criteria.stub(:translate).and_return(@criteria)
    end

    it "creates a criteria" do
      MongoDoc::Criteria.should_receive(:translate).with(FindersTest, @conditions).and_return(@criteria)
      FindersTest.find(:first, @conditions)
    end

    [:all, :first, :last].each do |which|
      it "calls #{which} on the criteria" do
        @criteria.should_receive(which)
        FindersTest.find(which, @conditions)
      end
    end
  end

  context ".find_one" do
    context "with an id" do
      it "calls translate with the id" do
        id = 'an id'
        MongoDoc::Criteria.should_receive(:translate).with(FindersTest, id)
        FindersTest.find_one(id)
      end
    end

    context "with conditions" do
      before do
        @criteria = stub('criteria').as_null_object
        @conditions = {:where => 'this.a > 3'}
      end

      it "calls translate with the conditions" do
        MongoDoc::Criteria.should_receive(:translate).with(FindersTest, @conditions).and_return(@criteria)
        FindersTest.find_one(@conditions)
      end

      it "call :one on the result" do
        MongoDoc::Criteria.stub(:translate).and_return(@criteria)
        @criteria.should_receive(:one)
        FindersTest.find_one(@conditions)
      end
    end
  end

  context "all other finders" do
    before do
      @criteria = stub('criteria').as_null_object
      MongoDoc::Criteria.stub(:new).and_return(@criteria)
    end

    [:all, :count, :first, :last].each do |which|
      it "calls #{which} on the new criteria" do
        @criteria.should_receive(which)
        FindersTest.send(which)
      end
    end
  end
end
