require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoDoc::Document id handling" do
  class Child < MongoDoc::Document
  end

  class Parent < MongoDoc::Document
    has_one :child
    has_many :children

    key :data

    validates_presence_of :data
  end

  context "as a has one child" do
    it "when added to the parent is a new record" do
      child = Child.new
      parent = Parent.new(:data => 'data', :child => child)
      child.should be_new_record
    end

    context "creating" do
      before do
        @id = 'id'
        @collection = stub('collection')
        @collection.stub(:insert).and_return(@id)
        Parent.stub(:collection).and_return(@collection)
      end

      context ".create" do
        it "when created is not a new record" do
          child = Child.new
          parent = Parent.create(:data => 'data', :child => child)
          child.should_not be_new_record
        end

        it "if parent is invalid, remains a new record" do
          child = Child.new
          parent = Parent.create(:child => child)
          child.should be_new_record
        end
      end

      context ".create!" do
        it "when created is not a new record" do
          child = Child.new
          parent = Parent.create!(:data => 'data', :child => child)
          child.should_not be_new_record
        end

        it "if parent is invalid, remains a new record" do
          child = Child.new
          Parent.create!(:child => child) rescue nil
          child.should be_new_record
        end
      end
    end

    context "saving" do
      before do
        @id = 'id'
        @collection = stub('collection')
        @collection.stub(:save).and_return(@id)
        Parent.stub(:collection).and_return(@collection)
      end

      context "#save" do
        it "when saved is not a new record" do
          child = Child.new
          parent = Parent.new(:data => 'data', :child => child)
          parent.save
          child.should_not be_new_record
        end

        it "if parent is invalid, remains a new record" do
          child = Child.new
          parent = Parent.new(:child => child)
          parent.save
          child.should be_new_record
        end
      end

      context "#save!" do
        it "when saved is not a new record" do
          child = Child.new
          parent = Parent.new(:data => 'data', :child => child)
          parent.save!
          child.should_not be_new_record
        end

        it "if parent is invalid, remains a new record" do
          child = Child.new
          parent = Parent.new(:child => child)
          parent.save! rescue nil
          child.should be_new_record
        end
      end
    end
  end

  context "as a has many child" do
    it "when added to the parent is a new record" do
      child = Child.new
      parent = Parent.new(:data => 'data')
      parent.children << child
      child.should be_new_record
    end

    context "creating" do
      before do
        @id = 'id'
        @collection = stub('collection')
        @collection.stub(:insert).and_return(@id)
        Parent.stub(:collection).and_return(@collection)
      end

      context ".create" do
        it "when created is not a new record" do
          child = Child.new
          parent = Parent.create(:data => 'data', :children => [child])
          child.should_not be_new_record
        end

        it "if parent is invalid, remains a new record" do
          child = Child.new
          parent = Parent.create(:children => [child])
          child.should be_new_record
        end
      end

      context ".create!" do
        it "when created is not a new record" do
          child = Child.new
          parent = Parent.create!(:data => 'data', :children => [child])
          child.should_not be_new_record
        end

        it "if parent is invalid, remains a new record" do
          child = Child.new
          Parent.create!(:children => [child]) rescue nil
          child.should be_new_record
        end
      end
    end

    context "saving" do
      before do
        @id = 'id'
        @collection = stub('collection')
        @collection.stub(:save).and_return(@id)
        Parent.stub(:collection).and_return(@collection)
      end

      context "#save" do
        it "when saved is not a new record" do
          child = Child.new
          parent = Parent.new(:data => 'data')
          parent.children << child
          parent.save
          child.should_not be_new_record
        end

        it "if parent is invalid, remains a new record" do
          child = Child.new
          parent = Parent.new
          parent.children << child
          parent.save
          child.should be_new_record
        end
      end

      context "#save!" do
        it "when saved is not a new record" do
          child = Child.new
          parent = Parent.new(:data => 'data')
          parent.children << child
          parent.save!
          child.should_not be_new_record
        end

        it "if parent is invalid, remains a new record" do
          child = Child.new
          parent = Parent.new
          parent.children << child
          parent.save! rescue nil
          child.should be_new_record
        end
      end
    end
  end
end
