require 'spec_helper'

describe MongoDoc::References do
  class Address
    include MongoDoc::Document

    attr_accessor :state
  end

  context "Simple Reference" do
    class Person
      include MongoDoc::Document

      references :address
    end

    subject { Person.new }

    context "Object accessor" do
      it { should respond_to(:address) }
      it { should respond_to(:address=) }

      it "is not part of the persistent key set" do
        Person._keys.should_not include(:address)
      end
    end

    context "Object Id accessor" do
      it { should respond_to(:address_id) }
      it { should respond_to(:address_id=) }

      it "is part of the persistent key set" do
        Person._keys.should include(:address_id)
      end
    end
  end

  context "Named Reference" do
    class Person
      include MongoDoc::Document

      references :address, :as => :work_address
    end

    subject { Person.new }

    context "Object accessor" do
      it { should respond_to(:work_address) }
      it { should respond_to(:work_address=) }

      it "is not part of the persistent key set" do
        Person._keys.should_not include(:work_address)
      end
    end

    context "Object Id accessor" do
      it { should respond_to(:work_address_id) }
      it { should respond_to(:work_address_id=) }

      it "is part of the persistent key set" do
        Person._keys.should include(:work_address_id)
      end
    end
  end

  describe "setting the id" do
    class Person
      include MongoDoc::Document

      references :address
    end

    let(:address) { Address.new(:_id => BSON::ObjectID.new) }
    let(:person) { Person.new }

    it "resets the object to nil" do
      person.address = address
      person.address_id = nil
      person.address.should be_nil
    end
  end
end
