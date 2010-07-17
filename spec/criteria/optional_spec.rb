require 'spec_helper'

describe Mongoid::Criterion::Optional do
  class OptionalTest
    include MongoDoc::Document
  end

  let(:criteria) { Mongoid::Criteria.new(OptionalTest) }
  let(:id) { BSON::ObjectID.new }
  let(:string_id) { id.to_s }

  describe "#id" do
    it "converts a string id to bson ids" do
      criteria.id(string_id)
      BSON::ObjectID.should === criteria.selector[:_id]
    end

    it "converts many string ids to bson ids" do
      criteria.id(string_id, string_id)
      criteria.selector[:_id].should have_key('$in')
      criteria.selector[:_id]['$in'].each do |selector_id|
        BSON::ObjectID.should === selector_id
      end
    end
  end
end
