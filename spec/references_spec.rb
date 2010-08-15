require 'spec_helper'

describe MongoDoc::References do
  class Address
    include MongoDoc::Document

    attr_accessor :state
  end

  context "Simple Reference" do
    class SimplePerson
      include MongoDoc::Document

      references :address
    end

    subject { SimplePerson.new }

    context "Object accessor" do
      it { should respond_to(:address) }
      it { should respond_to(:address=) }

      it "is not part of the persistent key set" do
        SimplePerson._keys.should_not include(:address)
      end
    end

    context "Object Id accessor" do
      it { should respond_to(:address_id) }
      it { should respond_to(:address_id=) }

      it "is part of the persistent key set" do
        SimplePerson._keys.should include(:address_id)
      end
    end

    context "setting the id" do
      let(:address) { Address.new(:_id => BSON::ObjectID.new) }

      it "resets the object to nil" do
        subject.address = address
        subject.address_id = nil
        subject.address.should be_nil
      end
    end
  end

  context "Named Reference" do
    class NamedPerson
      include MongoDoc::Document

      references :address, :as => :work_address
    end

    subject { NamedPerson.new }

    context "Object accessor" do
      it { should respond_to(:work_address) }
      it { should respond_to(:work_address=) }

      it "is not part of the persistent key set" do
        NamedPerson._keys.should_not include(:work_address)
      end
    end

    context "Object Id accessor" do
      it { should respond_to(:work_address_id) }
      it { should respond_to(:work_address_id=) }

      it "is part of the persistent key set" do
        NamedPerson._keys.should include(:work_address_id)
      end
    end
  end

  context "DBRef Reference" do
    class DBRefPerson
      include MongoDoc::Document

      references :as_ref => :address
    end

    let(:address) { Address.new(:_id => BSON::ObjectID.new) }
    subject { DBRefPerson.new }

    context "Object accessor" do
      it { should respond_to(:address) }
      it { should respond_to(:address=) }

      it "is not part of the persistent key set" do
        DBRefPerson._keys.should_not include(:address)
      end
    end

    context "DBRef accessor" do
      it { should respond_to(:address_ref) }
      it { should respond_to(:address_ref=) }

      it "is part of the persistent key set" do
        DBRefPerson._keys.should include(:address_ref)
      end
    end

    context "setting the object" do
      it "sets the reference" do
        subject.address = address
        subject.address_ref.namespace.should == Address.collection_name
        subject.address_ref.object_id.should == address._id
      end
    end

    context "setting the reference" do

      it "resets the object to nil" do
        subject.address = address
        subject.address_ref = nil
        subject.address.should be_nil
      end
    end
  end
end
