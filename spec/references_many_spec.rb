require 'spec_helper'

describe MongoDoc::ReferencesMany do
  class Address
    include MongoDoc::Document

    attr_accessor :state
  end

  context "Simple Reference" do
    class Person
      include MongoDoc::Document

      references_many :addresses
    end

    let(:person) { Person.new }
    subject { person }

    context "Object accessor" do
      it { should respond_to(:addresses) }
      it { should respond_to(:addresses=) }

      it "is not part of the persistent key set" do
        Person._keys.should_not include('addresses')
      end
    end

    context "Object Id accessor" do
      it { should respond_to(:address_ids) }
      it { should respond_to(:address_ids=) }

      it "is part of the persistent key set" do
        Person._keys.should include('address_ids')
      end
    end

    context "setting the ids" do
      let(:address) { Address.new(:_id => BSON::ObjectID.new) }

      context "to" do
        before do
          person.addresses = [address]
        end

        context "nil" do
          before do
            person.address_ids = nil
          end

          it "sets the ids to []" do
            person.address_ids.should == []
          end

          it "resets the objects to nil" do
            person.addresses.should == []
          end
        end

        it "[] resets the objects to []" do
          person.address_ids = []
          person.addresses.should == []
        end
      end

      context "to strings" do
        it "converts the strings to ids" do
          person.address_ids = [address._id.to_s]
          person.address_ids.should == [address._id]
        end
      end
    end
  end

  context "Named Reference" do
    class Person
      include MongoDoc::Document

      references_many :addresses, :as => :known_addresses
    end

    let(:person) { Person.new }

    subject { person }

    context "Object accessor" do
      it { should respond_to(:known_addresses) }
      it { should respond_to(:known_addresses=) }

      it "is not part of the persistent key set" do
        Person._keys.should_not include('known_addresses')
      end
    end

    context "Object Id accessor" do
      it { should respond_to(:known_address_ids) }
      it { should respond_to(:known_address_ids=) }

      it "is part of the persistent key set" do
        Person._keys.should include('known_address_ids')
      end
    end

    context "setting the ids" do
      let(:address) { Address.new(:_id => BSON::ObjectID.new) }

      context "to" do
        before do
          person.known_addresses = [address]
        end

        context "nil" do
          before do
            person.known_address_ids = nil
          end

          it "sets the ids to []" do
            person.known_address_ids.should == []
          end

          it "resets the objects to nil" do
            person.known_addresses.should == []
          end
        end

        it "[] resets the objects to []" do
          person.known_address_ids = []
          person.known_addresses.should == []
        end
      end

      context "to strings" do
        it "converts the strings to ids" do
          person.known_address_ids = [address._id.to_s]
          person.known_address_ids.should == [address._id]
        end
      end
    end
  end

  context "DBRef reference" do
    class PersonDBRef
      include MongoDoc::Document

      references_many :as_ref => :addresses
    end

    let(:address) { Address.new(:_id => BSON::ObjectID.new) }
    let(:person) { PersonDBRef.new }

    subject { person }

    context "Object accessor" do
      it { should respond_to(:addresses) }
      it { should respond_to(:addresses=) }

      it "is not part of the persistent key set" do
        PersonDBRef._keys.should_not include('addresses')
      end
    end

    context "DBRef accessor" do
      it { should respond_to(:address_refs) }
      it { should respond_to(:address_refs=) }

      it "is part of the persistent key set" do
        PersonDBRef._keys.should include('address_refs')
      end
    end

    context "setting the collection" do
      before do
        person.addresses = [address]
      end

      it "sets the refs to an array of refs]" do
        person.address_refs.first.namespace.should == Address.collection_name
        person.address_refs.first.object_id.should == address._id
      end
    end

    context "setting the refs" do
      before do
        person.addresses = [address]
      end

      context "to nil" do
        before do
          person.address_refs = nil
        end

        it "sets the refs to []" do
          person.address_refs.should == []
        end

        its(:addresses) { should == [] }
      end

      context "to []" do
        before do
          person.address_refs = []
        end

        its(:addresses) { should == [] }
      end

      context "to an array of references" do
        let(:dbref) { ::BSON::DBRef.new(Address.collection_name, address._id) }

        before do
          person.address_refs = [dbref]
        end

        it "sets the addresses to nil" do
          person.instance_variable_get('@addresses').should be_nil
        end
      end
    end
  end
end
