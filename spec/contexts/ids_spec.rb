require 'spec_helper'

describe "MongoDoc::Contexts::Ids" do

  class Address
    include MongoDoc::Document
    include MongoDoc::Matchers

    attr_accessor :number
    attr_accessor :street
  end

  let(:criteria) { Mongoid::Criteria.new(Address) }
  let(:context) { criteria.context }

  context "#id_criteria" do
    context "single id" do
      let(:id) { 'a' * 24 }
      let(:obj_id) { BSON::ObjectID.from_string(id) }

      it "converts strings to an object id" do
        criteria.should_receive(:id).with(obj_id)
        context.stub(:one)
        context.id_criteria(id)
      end

      it "delegates to one if passed a string or ObjectID" do
        context.should_receive(:one)
        context.id_criteria(id)
      end
    end

    context "mutliple ids" do
      let(:ids) { ['a' * 24, 'b' * 24] }
      let(:obj_ids) { [BSON::ObjectID.from_string(ids.first), BSON::ObjectID.from_string(ids.last)] }

      it "converts strings to an object id" do
        criteria.should_receive(:id).with(obj_ids)
        criteria.stub(:entries)
        context.id_criteria(ids)
      end

      it "delegates to entries if passed an array" do
        criteria.should_receive(:entries)
        context.id_criteria(ids)
      end
    end
  end
end
