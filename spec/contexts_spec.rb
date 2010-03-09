require "spec_helper"

describe MongoDoc::Contexts do

  class ContextTest
    include MongoDoc::Document

    has_many :children
  end

  context ".context_for" do
    let(:criteria) { stub('criteria', :klass => klass) }

    context "when criteria is for a top-level MongoDoc::Document" do
      let(:klass) { ContextTest }

      it "creates a Mongo context" do
        MongoDoc::Contexts::Mongo.should_receive(:new).with(criteria)
        Mongoid::Contexts.context_for(criteria)
      end
    end

    context "when criteria is for an association" do
      let(:klass) { ContextTest.new.children }

      it "creates an Enumerable context" do
        MongoDoc::Contexts::Enumerable.should_receive(:new).with(criteria)
        Mongoid::Contexts.context_for(criteria)
      end
    end

    context "when criteria is for a MongoDoc::Collection" do
      let(:klass) { MongoDoc::Collection.new('collection') }

      before do
        MongoDoc::Collection.stub(:mongo_collection).and_return(stub('collection'))
      end

      it "creates a Mongo context" do
        MongoDoc::Contexts::Mongo.should_receive(:new).with(criteria)
        Mongoid::Contexts.context_for(criteria)
      end
    end

    context "when criteria is not recognized" do
      let(:klass) { Object }

      it "raises an exception" do
        expect do
          Mongoid::Contexts.context_for(criteria)
        end.should raise_error(Mongoid::Contexts::UnknownContext)
      end
    end
  end
end

