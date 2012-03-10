require 'spec_helper'

describe MongoDoc::ReferencesMany do
  class PostalAddress
    include MongoDoc::Document

    attr_accessor :state
  end

  context "Simple Reference" do
    class PersonSimple
      include MongoDoc::Document

      references_many :postal_addresses
    end

    let(:person) { PersonSimple.new }
    subject { person }

    context "Object accessor" do
      it { should respond_to(:postal_addresses) }
      it { should respond_to(:postal_addresses=) }

      it "is not part of the persistent key set" do
        PersonSimple._keys.should_not include(:postal_addresses)
      end
    end

    context "Object Id accessor" do
      it { should respond_to(:postal_address_ids) }
      it { should respond_to(:postal_address_ids=) }

      it "is part of the persistent key set" do
        PersonSimple._keys.should include(:postal_address_ids)
      end
    end

    context "setting the ids" do
      let(:postal_address) { PostalAddress.new(:_id => BSON::ObjectId.new) }

      before do
        person.postal_addresses = [postal_address]
      end

      context "to nil" do
        before do
          person.postal_address_ids = nil
        end

        its(:postal_address_ids) { should == [] }
        its(:postal_addresses) { should == [] }
      end

      context "to []" do
        before do
          person.postal_address_ids = []
        end

        its(:postal_addresses) { should == [] }
      end

      context "to strings" do
        before do
          person.postal_address_ids = [postal_address._id.to_s]
        end

        its(:postal_address_ids) { should == [postal_address._id] }
      end
    end
  end

  context "Named Reference" do
    class PersonNamed
      include MongoDoc::Document

      references_many :postal_addresses, :as => :known_addresses
    end

    let(:person) { PersonNamed.new }

    subject { person }

    context "Object accessor" do
      it { should respond_to(:known_addresses) }
      it { should respond_to(:known_addresses=) }

      it "is not part of the persistent key set" do
        PersonNamed._keys.should_not include(:known_addresses)
      end
    end

    context "Object Id accessor" do
      it { should respond_to(:known_address_ids) }
      it { should respond_to(:known_address_ids=) }

      it "is part of the persistent key set" do
        PersonNamed._keys.should include(:known_address_ids)
      end
    end

    context "setting the ids" do
      let(:address) { PostalAddress.new(:_id => BSON::ObjectId.new) }

      before do
        person.known_addresses = [address]
      end

      context "to nil" do
        before do
          person.known_address_ids = nil
        end

        its(:known_address_ids) { should == [] }
        its(:known_addresses) { should == [] }
      end

      context "to []" do
        before do
          person.known_address_ids = []
        end

        its(:known_addresses) { should == [] }
      end

      context "to strings" do
        before do
          person.known_address_ids = [address._id.to_s]
        end

        its(:known_address_ids) { should == [address._id] }
      end
    end
  end

  context "DBRef reference" do
    class PersonDBRef
      include MongoDoc::Document

      references_many :as_ref => :addresses
    end

    let(:address) { PostalAddress.new(:_id => BSON::ObjectId.new) }
    let(:person) { PersonDBRef.new }

    subject { person }

    context "Object accessor" do
      it { should respond_to(:addresses) }
      it { should respond_to(:addresses=) }

      it "is not part of the persistent key set" do
        PersonDBRef._keys.should_not include(:addresses)
      end
    end

    context "DBRef accessor" do
      it { should respond_to(:address_refs) }
      it { should respond_to(:address_refs=) }

      it "is part of the persistent key set" do
        PersonDBRef._keys.should include(:address_refs)
      end
    end

    context "setting the collection" do
      before do
        person.addresses = [address]
      end

      it "sets the refs to an array of refs]" do
        person.address_refs.first.namespace.should == PostalAddress.collection_name
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
        let(:dbref) { ::BSON::DBRef.new(PostalAddress.collection_name, address._id) }

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
