require 'spec_helper'

describe MongoDoc::Configuration do
  describe ".dynamic_attributes" do
    after { MongoDoc::Configuration.dynamic_attributes = false }

    subject { MongoDoc::Configuration.dynamic_attributes }

    it { should be_false }

    it "can be set to true" do
      MongoDoc::Configuration.dynamic_attributes = true
      subject.should be_true
    end
  end
end
