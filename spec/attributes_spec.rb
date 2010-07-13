require 'spec_helper'

describe "MongoDoc::Attributes" do
  class AttributesTest
    include MongoDoc::Attributes
  end

  it "defines _id attribute" do
    AttributesTest.new.should respond_to(:_id)
    AttributesTest.new.should respond_to(:_id=)
  end

  context ".key" do
    class AttributeAccessorTest
      include MongoDoc::Attributes

      key :date, :default => Date.today, :type => Date
    end

    it "is an alias for attr_accessor" do
      AttributeAccessorTest._keys.should include(:date)
    end
  end

  context ".attr_accessor" do
    class TestKeys
      include MongoDoc::Attributes

      attr_accessor :attr1, :attr2
      attr_accessor :validation_context
    end

    it "adds its arguments to _keys" do
      TestKeys._keys.should include(:attr1, :attr2)
    end

    context "the :validation_context attribute from ActiveModel" do

      it "is an attribute" do
        TestKeys.new.should respond_to(:validation_context)
        TestKeys.new.should respond_to(:validation_context=)
      end

      it "is not in _keys" do
        TestKeys._keys.should_not include(:validation_context)
      end
    end

    describe "accessors" do
      subject do
        TestKeys.new
      end

      it "has an attr1 reader" do
        should respond_to(:attr1)
      end

      it "has an attr1 writer" do
        should respond_to(:attr1=)
      end
    end

    context "default values" do
      class TestDefault
        include MongoDoc::Attributes

        attr_accessor :with_default, :default => 'value'
      end

      let(:object) { TestDefault.new }

      it "uses the default value" do
        object.with_default.should == 'value'
      end

      it "only uses the default value once" do
        object.with_default.should == 'value'
        class << object
          def _default_with_default
            'other value'
          end
        end
        object.with_default.should == 'value'
      end

      it "does not set the default value if the setter is invoked first" do
        object.with_default = nil
        object.with_default.should be_nil
      end
    end

    context "specified type" do
      class TestType
        include MongoDoc::Attributes

        attr_accessor :birthdate, :type => Date
      end

      let(:object) { TestType.new }

      it "does not call Type.cast_from_string when the set value is not a string" do
        Date.should_not_receive :cast_from_string
        object.birthdate = Date.today
      end

      context "when the accessor is set with a string" do
        let(:date) { Date.today }

        it "delegates to Type.cast_from_string to set the value" do
          Date.should_receive(:cast_from_string).with(date.to_s)
          object.birthdate = date.to_s
        end

        it "sets the value to the result of the cast" do
          object.birthdate = date.to_s
          object.birthdate.should == date
        end
      end

      context "when a namespace collision exists" do
        class TestType
          attr_accessor :bson_id, :type => ::BSON::ObjectID
        end

        let(:bson_id) { ::BSON::ObjectID.new }
        it "sets the value to the result of the cast" do
          object.bson_id = bson_id.to_s
          object.bson_id.should == bson_id
        end
      end
    end

    describe "used with inheritance" do
      class TestParent
        include MongoDoc::Attributes

        attr_accessor :parent_attr
      end

      class TestChild < TestParent
        attr_accessor :child_attr
      end

      it "has its own keys" do
        TestChild._keys.should include(:child_attr)
      end

      it "has the keys from the parent class" do
        TestChild._keys.should include(*TestParent._keys)
      end

      it "does not add keys to the parent class" do
        TestParent._keys.should_not include(:child_attr)
      end
    end
  end

  context "._attributes" do
    class TestHasOneDoc
      include MongoDoc::Document

      attr_accessor :key
      embed :embed
    end

    it "is _keys + _associations" do
      TestHasOneDoc._attributes.should == TestHasOneDoc._keys + TestHasOneDoc._associations
    end
  end
end
