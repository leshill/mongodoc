require "spec_helper"

describe MongoDoc::Contexts do

  context ".context_for" do
    let(:criteria) { stub('criteria', :klass => klass) }

    context "when criteria is for an embedded MongoDoc::Document" do
      let(:klass) { stub('klass') }

      it "creates an Enumerable context" do
        MongoDoc::Contexts::Enumerable.should_receive(:new).with(criteria)
        Mongoid::Contexts.context_for(criteria)
      end
    end
  end

end

