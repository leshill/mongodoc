require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoDoc::Document::Attributes" do
  context ".key" do
    class TestKeys < MongoDoc::Base
    end

    it "adds its arguments to _keys" do
      TestKeys.key :attr1, :attr2
      TestKeys._keys.should == [:attr1, :attr2]
    end

    describe "accessors" do
      before do
        TestKeys.key :attr1
      end

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

    describe "used with inheritance" do
      class TestParent < MongoDoc::Base
        key :parent_attr
      end

      class TestChild < TestParent
        key :child_attr
      end

      it "has its own keys" do
        TestChild._keys.should include(:child_attr)
      end

      it "has the keys from the parent class" do
        TestChild._keys.should include(*TestParent._keys)
      end
    end
  end

  context ".has_one" do
    class TestDoc < MongoDoc::Base
      has_one :subdoc
    end

    class SubDoc < MongoDoc::Base
      key :data
    end

    it "sets the subdocuments parent" do
      subdoc = SubDoc.new
      doc = TestDoc.new(:subdoc => subdoc)
      subdoc._parent.should == doc
    end

    it "set the subdocuments root" do
      subdoc = SubDoc.new
      middoc = TestDoc.new
      doc = TestDoc.new(:subdoc => middoc)
      middoc.subdoc = subdoc
      subdoc._root.should == doc
    end

    it "sets the subdocuments root no matter how when it is inserted" do
      subdoc = SubDoc.new
      middoc = TestDoc.new(:subdoc => subdoc)
      doc = TestDoc.new(:subdoc => middoc)
      subdoc._root.should == doc
    end
  end

  context "._attributes" do
    class TestDoc < MongoDoc::Base
      key :key
      has_one :has_one
    end

    it "is _keys + _associations" do
      TestDoc._attributes.should == TestDoc._keys + TestDoc._associations
    end
  end
end