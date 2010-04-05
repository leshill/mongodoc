require 'spec_helper'

describe MongoDoc::Validations do

  class ValidationTest
    include MongoDoc::Document

    attr_accessor :data
    validates_presence_of :data
  end

  context "requirements" do
    subject { ValidationTest.new }

    it { should respond_to(:valid?) }
    it { should respond_to(:errors) }

    it "is included by Document" do
      MongoDoc::Validations.should === subject
    end
  end

  context "validations" do
    it "valid? fails when a document is invalid" do
      doc = ValidationTest.new
      doc.should_not be_valid
      doc.should have(1).error_on(:data)
    end
  end
end
