require 'spec_helper'

describe MongoDoc::References do
  class PostalAddress
    include MongoDoc::Document

    attr_accessor :state
  end

  context "Simple Reference" do
    class SimplePerson
      include MongoDoc::Document

      references :postal_address
    end

    subject { SimplePerson.new }

    context "Object accessor" do
      it { should respond_to(:postal_address) }
      it { should respond_to(:postal_address=) }

      it "is not part of the persistent key set" do
        SimplePerson._keys.should_not include(:postal_address)
      end
    end

    context "Object Id accessor" do
      it { should respond_to(:postal_address_id) }
      it { should respond_to(:postal_address_id=) }

      it "is part of the persistent key set" do
        SimplePerson._keys.should include(:postal_address_id)
      end
    end

    context "setting the id" do
      let(:postal_address) { PostalAddress.new(:_id => BSON::ObjectID.new) }

      it "resets the object to nil" do
        subject.postal_address = postal_address
        subject.postal_address_id = nil
        subject.postal_address.should be_nil
      end
    end
  end

  context "Named Reference" do
    class NamedPerson
      include MongoDoc::Document

      references :postal_address, :as => :work_address
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

    let(:address) { PostalAddress.new(:_id => BSON::ObjectID.new) }
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
        subject.address_ref.namespace.should == PostalAddress.collection_name
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
