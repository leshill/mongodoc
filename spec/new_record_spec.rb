require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoDoc::Document _id and #new_record?" do
  class Child
    include MongoDoc::Document
  end

  class Parent
    include MongoDoc::Document

    has_one :child
    has_many :children

    attr_accessor :data

    validates_presence_of :data
  end

  let(:id) { 'id' }
  let(:collection) { stub('collection', :save => id) }
  let(:child) { Child.new }

  context "as a has_one child" do
    it "when added to the parent is a new record" do
      Parent.new(:data => 'data', :child => child)
      child.should be_new_record
    end

    context "saving" do
      before do
        Parent.stub(:collection).and_return(collection)
      end

      context "#save" do
        it "when saved is not a new record" do
          parent = Parent.new(:data => 'data', :child => child)
          parent.save
          child.should_not be_new_record
        end

        it "if parent is invalid, remains a new record" do
          parent = Parent.new(:child => child)
          parent.save
          child.should be_new_record
        end
      end

      context "#save!" do
        it "when saved is not a new record" do
          parent = Parent.new(:data => 'data', :child => child)
          parent.save!
          child.should_not be_new_record
        end

        it "if parent is invalid, remains a new record" do
          parent = Parent.new(:child => child)
          parent.save! rescue nil
          child.should be_new_record
        end

        it "when db error is raised, remains a new record" do
          collection.stub(:save).and_raise(Mongo::OperationFailure)
          parent = Parent.new(:data => 'data', :child => child)
          expect do
            parent.save!
          end.should raise_error(Mongo::OperationFailure)
          child.should be_new_record
        end
      end
    end
  end

  context "as a has_many child" do
    it "when added to the parent is a new record" do
      parent = Parent.new(:data => 'data')
      parent.children << child
      child.should be_new_record
    end

    context "saving" do
      before do
        Parent.stub(:collection).and_return(collection)
      end

      context "#save" do
        it "when saved is not a new record" do
          parent = Parent.new(:data => 'data')
          parent.children << child
          parent.save
          child.should_not be_new_record
        end

        it "if parent is invalid, remains a new record" do
          parent = Parent.new
          parent.children << child
          parent.save
          child.should be_new_record
        end
      end

      context "#save!" do
        it "when saved is not a new record" do
          parent = Parent.new(:data => 'data')
          parent.children << child
          parent.save!
          child.should_not be_new_record
        end

        it "if parent is invalid, remains a new record" do
          parent = Parent.new
          parent.children << child
          parent.save! rescue nil
          child.should be_new_record
        end

        it "when db error is raised, remains a new record" do
          collection.stub(:save).and_raise(Mongo::OperationFailure)
          parent = Parent.new(:data => 'data')
          parent.children << child
          expect do
            parent.save!
          end.should raise_error(Mongo::OperationFailure)
          child.should be_new_record
        end
      end
    end
  end
end
