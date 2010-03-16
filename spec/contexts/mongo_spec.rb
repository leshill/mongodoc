require 'spec_helper'

describe "MongoDoc::Contexts::Mongo" do

  class Address
    include MongoDoc::Document
    include MongoDoc::Matchers

    attr_accessor :number
    attr_accessor :street
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

    context "#avg" do
      it "is the sum/count" do
        context.should_receive(:count).and_return(1)
        context.should_receive(:sum).with(:field_name).and_return(1)
        context.avg(:field_name)
      end

      it "returns nil if there is no sum" do
        context.stub(:sum).and_return(nil)
        context.avg(:field_name).should be_nil
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

    context "#distinct" do
      it "uses distinct" do
        collection.should_receive(:distinct).with(:field_name, {})
        context.distinct(:field_name)
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

    context "#iterate" do

      it "delegates to caching if cached" do
        context.should_receive(:caching)
        criteria.cache
        context.iterate
      end

      it "iterates over the results of execute" do
        item = stub('item')
        context.stub(:execute).and_return([item])
        context.iterate do |doc|
          doc.should == item
        end
      end

      context "#caching" do
        let(:item) { stub('item') }

        before do
          criteria.cache
        end

        context "when not previously cached" do
          it "iterates over the results of execute" do
            context.stub(:execute).and_return([item])
            context.iterate do |doc|
              doc.should == item
            end
          end

          it "memoizes the result" do
            context.stub(:execute).and_return([item])
            context.iterate
            context.cache.should == [item]
          end
        end

        context "when previously cached" do
          before do
            context.instance_variable_set(:@cache, [item])
          end

          it "does not execute" do
            context.should_not_receive(:execute)
            context.iterate do |doc|
              doc.should == item
            end
          end

          it "iterates over the results of execute" do
            context.should_not_receive(:execute)
            acc = []
            context.iterate do |doc|
              acc << doc
            end
            acc.should == [item]
          end
        end
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

    context "#empty? or #blank?" do
      it "delegates to find_one" do
        collection.should_receive(:find_one).with({}, {})
        context.empty?
      end

      it "returns true if find_one returns no result" do
        collection.stub(:find_one).and_return(nil)
        context.should be_blank
      end

      it "returns false if find_one returns any result" do
        collection.stub(:find_one).and_return(stub('result'))
        context.should_not be_empty
      end
    end
  end
end
