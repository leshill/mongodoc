require 'spec_helper'

describe "MongoDoc::Contexts::MongoDoc" do

  class Address
    include MongoDoc::Document
    include MongoDoc::Matchers

    key :number
    key :street
  end

  let(:criteria) { Mongoid::Criteria.new(Address) }
  let(:context) { criteria.context }

  context "#initialize" do
    it "sets the criteria" do
      context.criteria.should == criteria
    end
  end

  context "#collection" do
    it "delegates to klass" do
      klass = mock('klass', :collection => true)
      context.should_receive(:klass).and_return(klass)
      context.collection
    end
  end

  context "querying" do
    let(:collection) { stub('collection') }

    before { context.stub(:collection).and_return(collection) }

    context "#aggregate" do
      it "uses group with the appropriate JS" do
        collection.should_receive(:group).with(nil, {}, {:count=>0}, MongoDoc::Contexts::Mongo::AGGREGATE_REDUCE, true)
        context.aggregate
      end
    end

    context "#count" do
      it "uses find and count" do
        result = stub('result')
        result.should_receive(:count)
        collection.should_receive(:find).and_return(result)
        context.count
      end
    end

    context "#execute" do
      it "uses find" do
        collection.should_receive(:find)
        context.execute
      end

      it "returns [] if nothing returned from find" do
        collection.stub(:find => nil)
        context.execute.should == []
      end

      it "returns the cursor if one is returned from find" do
        cursor = stub('cursor')
        collection.stub(:find => cursor)
        context.execute.should == cursor
      end

      it "memoizes the count if paginating" do
        count = 20
        cursor = stub('cursor', :count => count)
        collection.stub(:find => cursor)
        context.execute
        context.count.should == count
      end
    end

    context "#group" do
      it "uses group with the appropriate JS" do
        collection.should_receive(:group).with(nil, {}, {:group=>[]}, MongoDoc::Contexts::Mongo::GROUP_REDUCE, true).and_return([])
        context.group
      end

      it "decodes returned documents" do
        doc = stub('doc')
        collection.stub(:group).and_return([{:group => [doc]}])
        MongoDoc::BSON.should_receive(:decode).and_return(doc)
        context.group
      end
    end

    context "#id_criteria" do
      it "delegates to one if passed a string or ObjectID" do
        context.should_receive(:one)
        context.id_criteria('id')
      end

      it "delegates to entries if passed an array" do
        criteria.should_receive(:entries)
        context.id_criteria(['id'])
      end
    end

    context "#last" do
      it "delegates to find_one" do
        collection.should_receive(:find_one).with({}, {:sort=>[[:_id, :desc]]})
        context.last
      end
    end

    context "#max" do
      it "delegates to grouped" do
        context.should_receive(:grouped).with(:max, "number", MongoDoc::Contexts::Mongo::MAX_REDUCE)
        context.max(:number)
      end
    end

    context "#min" do
      it "delegates to grouped" do
        context.should_receive(:grouped).with(:min, "number", MongoDoc::Contexts::Mongo::MIN_REDUCE)
        context.min(:number)
      end
    end

    context "#one" do
      it "delegates to find_one" do
        collection.should_receive(:find_one).with({}, {})
        context.one
      end
    end

    context "#sum" do
      it "delegates to grouped" do
        context.should_receive(:grouped).with(:sum, "number", MongoDoc::Contexts::Mongo::SUM_REDUCE)
        context.sum(:number)
      end
    end

    context "#grouped" do
      it "delegates to group" do
        op = 'op'
        field = 'name'
        reduce = '[field]'
        collection.should_receive(:group).with(nil, {}, {op =>"start"}, field, true).and_return([])
        context.send(:grouped, op, field, reduce)
      end
    end
  end
end