require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper.rb"))

describe MongoDoc::Criteria do
  class CountryCode < MongoDoc::Document
    key :code
  end

  class Phone < MongoDoc::Document
    key :number
    has_one :country_code
  end

  class Animal < MongoDoc::Document
    key :name
  end

  class Address < MongoDoc::Document
    key :street
    key :city
    key :state
    key :post_code
  end

  class Name < MongoDoc::Document
    key :first_name
    key :last_name
  end

  class Person < MongoDoc::Document
    key :title
    key :terms
    key :age
    key :dob
    key :mixed_drink
    key :employer_id
    key :lunch_time

    has_many :addresses
    has_many :phone_numbers, :class_name => "Phone"

    has_one :name
    has_one :pet

    def update_addresses
      addresses.each_with_index do |address, i|
        address.street = "Updated #{i}"
      end
    end

    def employer=(emp)
      self.employer_id = emp.id
    end
  end

  before do
    @criteria = MongoDoc::Criteria.new(Person)
  end

  describe "#all" do
    it "calls collect" do
      @criteria.should_receive(:collect).with(no_args)
      @criteria.all
    end
  end

  describe "#aggregate" do
    before do
      @reduce = "function(obj, prev) { prev.count++; }"
      @collection = mock
      Person.should_receive(:collection).and_return(@collection)
    end

    it "calls group on the collection with the aggregate js" do
      @collection.should_receive(:group).with([:field1], {}, {:count => 0}, @reduce)
      @criteria.select(:field1).aggregate
    end
  end

  describe "#every" do

    it "adds the $all query to the selector" do
      @criteria.every(:title => ["title1", "title2"])
      @criteria.selector.should == { :title => { "$all" => ["title1", "title2"] } }
    end

    it "and_return self" do
      @criteria.every(:title => [ "title1" ]).should == @criteria
    end

  end

  describe "including Enumerable" do

    before do
      @cursor = stub('cursor').as_null_object
      @criteria.stub(:execute).and_return(@cursor)
    end

    it "calls each" do
      @criteria.should_receive(:each).and_return(@criteria)
      @criteria.collect
    end

  end

  describe "#count" do

    context "when criteria has not been executed" do

      before do
        @count = 27
        @cursor = stub('cursor', :count => @count)
        Person.stub(:collection).and_return(@collection)
      end

      it "calls through to the collection" do
        @collection.should_receive(:find).and_return(@cursor)
        @criteria.count
      end

      it "returns the count from the cursor" do
        @collection.stub(:find).and_return(@cursor)
        @criteria.count.should == @count
      end

    end

    context "when criteria has been executed" do

      before do
        @count = 28
        @criteria.instance_variable_set(:@count, @count)
      end

      it "returns the count from the cursor without creating the documents" do
        @criteria.count.should == @count
      end

    end

  end

  describe "#each" do

    before do
      @criteria.where(:title => "Sir")
      @person = Person.new(:title => "Sir")
      @cursor = [@person]
    end

    context "when no block given" do
      it "executes the criteria" do
        @criteria.should_receive(:execute).and_return(@cursor)
        @criteria.each
      end

      it "has memoized the result of execute" do
        @criteria.stub(:execute).and_return(@cursor)
        @criteria.each
        @criteria.collection.should == @cursor
      end

      it "returns self" do
        @criteria.stub(:execute).and_return(@cursor)
        @criteria.each.should == @criteria
      end
    end

    context "when a block is given" do
      class CursorStub
        include Enumerable

        attr_accessor :data

        def each(*args, &block)
          data.each(*args, &block)
        end
      end

      context "when the criteria has not been executed" do
        before do
          @cursor = CursorStub.new
          @cursor.data = [@person]
        end

        it "executes the criteria" do
          @criteria.should_receive(:execute).and_return(@cursor)
          @criteria.each do |person|
            person.should == @person
          end
        end

        it "yields into the block" do
          @criteria.stub(:execute).and_return(@cursor)
          @criteria.each do |person|
            @result = person
          end
          @result.should == @person
        end

        it "has memoized the cursor iteration" do
          @criteria.stub(:execute).and_return(@cursor)
          @criteria.each do |person|
            @result = person
          end
          @criteria.collection.should == [@person]
        end


        it "returns self" do
          @criteria.stub(:execute).and_return(@cursor)
          @criteria.each.should == @criteria
        end
      end

      context "when the criteria has been executed" do
        before do
          @criteria.stub(:execute).and_return(@cursor)
          @criteria.each
        end

        it "does not execute the criteria" do
          @criteria.should_not_receive(:execute)
          @criteria.each do |person|
            person.should == @person
          end
        end

        it "yields into the block" do
          @criteria.each do |person|
            @result = person
          end
          @result.should == @person
        end

        it "returns self" do
          @criteria.each.should == @criteria
        end
      end
    end
  end

  describe "#excludes" do

    it "adds the $ne query to the selector" do
      @criteria.excludes(:title => "Bad Title", :text => "Bad Text")
      @criteria.selector.should == { :title => { "$ne" => "Bad Title"}, :text => { "$ne" => "Bad Text" } }
    end

    it "and_return self" do
      @criteria.excludes(:title => "Bad").should == @criteria
    end

  end

  describe "#extras" do

    context "filtering" do

      context "when page is provided" do

        it "sets the limit and skip options" do
          @criteria.extras({ :page => "2" })
          @criteria.page.should == 2
          @criteria.options.should == { :skip => 20, :limit => 20 }
        end

      end

      context "when per_page is provided" do

        it "sets the limit and skip options" do
          @criteria.extras({ :per_page => 45 })
          @criteria.options.should == { :skip => 0, :limit => 45 }
        end

      end

      context "when page and per_page both provided" do

        it "sets the limit and skip options" do
          @criteria.extras({ :per_page => 30, :page => "4" })
          @criteria.options.should == { :skip => 90, :limit => 30 }
          @criteria.page.should == 4
        end

      end

    end

    it "adds the extras to the options" do
      @criteria.extras({ :skip => 10 })
      @criteria.options.should == { :skip => 10 }
    end

    it "and_return self" do
      @criteria.extras({}).should == @criteria
    end

    it "adds the extras without overwriting existing options" do
      @criteria.order_by([:field1])
      @criteria.extras({ :skip => 10 })
      @criteria.options.should have_key(:sort)
    end

  end

  describe "#group" do
    before do
      @grouping = [{ "title" => "Sir", "group" => [{ "title" => "Sir", "age" => 30 }] }]
      @reduce = "function(obj, prev) { prev.group.push(obj); }"
      @collection = mock
      Person.should_receive(:collection).and_return(@collection)
    end

    it "calls group on the collection with the aggregate js" do
      @collection.should_receive(:group).with([:field1], {}, {:group => []}, @reduce).and_return(@grouping)
      @criteria.select(:field1).group
    end
  end

  describe "#id" do

    it "adds the ObjectID as the _id query to the selector" do
      id = Mongo::ObjectID.new
      @criteria.id(id)
      @criteria.selector.should == { :_id => id }
    end

    it "adds the string as the _id query to the selector" do
      id = Mongo::ObjectID.new.to_s
      @criteria.id(id)
      @criteria.selector.should == { :_id => id }
    end

    it "and_return self" do
      id = Mongo::ObjectID.new
      @criteria.id(id).should == @criteria
    end

  end

  describe "#in" do

    it "adds the $in clause to the selector" do
      @criteria.in(:title => ["title1", "title2"], :text => ["test"])
      @criteria.selector.should == { :title => { "$in" => ["title1", "title2"] }, :text => { "$in" => ["test"] } }
    end

    it "and_return self" do
      @criteria.in(:title => ["title1"]).should == @criteria
    end

  end

  describe "#last" do

    context "when documents exist" do

      before do
        @collection = mock
        Person.should_receive(:collection).and_return(@collection)
        @collection.should_receive(:find_one).with(@criteria.selector, { :sort => [[:title, :desc]] }).and_return(Person.new(:title => "Sir"))
      end

      it "calls find on the collection with the selector and sort options reversed" do
        @criteria.order_by([[:title, :asc]])
        @criteria.last.should be_a_kind_of(Person)
      end

    end

    context "when no documents exist" do

      before do
        @collection = mock
        Person.should_receive(:collection).and_return(@collection)
        @collection.should_receive(:find_one).with(@criteria.selector, { :sort => [[:_id, :desc]] }).and_return(nil)
      end

      it "and_return nil" do
        @criteria.last.should be_nil
      end

    end

    context "when no sorting options provided" do

      before do
        @collection = mock
        Person.should_receive(:collection).and_return(@collection)
        @collection.should_receive(:find_one).with(@criteria.selector, { :sort => [[:_id, :desc]] }).and_return({ :title => "Sir" })
      end

      it "defaults to sort by id" do
        @criteria.last
      end

    end

  end

  describe "#limit" do

    context "when value provided" do

      it "adds the limit to the options" do
        @criteria.limit(100)
        @criteria.options.should == { :limit => 100 }
      end

    end

    context "when value not provided" do

      it "defaults to 20" do
        @criteria.limit
        @criteria.options.should == { :limit => 20 }
      end

    end

    it "and_return self" do
      @criteria.limit.should == @criteria
    end

  end

  describe "#not_in" do

    it "adds the exclusion to the selector" do
      @criteria.not_in(:title => ["title1", "title2"], :text => ["test"])
      @criteria.selector.should == { :title => { "$nin" => ["title1", "title2"] }, :text => { "$nin" => ["test"] } }
    end

    it "and_return self" do
      @criteria.not_in(:title => ["title1"]).should == @criteria
    end

  end

  describe "#offset" do

    context "when the per_page option exists" do

      before do
        @criteria.extras({ :per_page => 20, :page => 3 })
      end

      it "and_return the per_page option" do
        @criteria.offset.should == 40
      end

    end

    context "when the skip option exists" do

      before do
        @criteria.extras({ :skip => 20 })
      end

      it "and_return the skip option" do
        @criteria.offset.should == 20
      end

    end

    context "when no option exists" do

      context "when page option exists" do

        before do
          @criteria.extras({ :page => 2 })
        end

        it "adds the skip option to the options and and_return it" do
          @criteria.offset.should == 20
          @criteria.options[:skip].should == 20
        end

      end

      context "when page option does not exist" do

        it "and_return nil" do
          @criteria.offset.should be_nil
          @criteria.options[:skip].should be_nil
        end

      end

    end

  end

  describe "#one" do

    context "when documents exist" do

      before do
        @collection = mock
        Person.should_receive(:collection).and_return(@collection)
        @collection.should_receive(:find_one).with(@criteria.selector, @criteria.options).and_return(Person.new(:title => "Sir"))
      end

      it "calls find on the collection with the selector and options" do
        @criteria.one.should be_a_kind_of(Person)
      end

    end

    context "when no documents exist" do

      before do
        @collection = mock
        Person.should_receive(:collection).and_return(@collection)
        @collection.should_receive(:find_one).with(@criteria.selector, @criteria.options).and_return(nil)
      end

      it "returns nil" do
        @criteria.one.should be_nil
      end

    end

  end

  describe "#order_by" do

    context "when field names and direction specified" do

      it "adds the sort to the options" do
        @criteria.order_by([[:title, :asc], [:text, :desc]])
        @criteria.options.should == { :sort => [[:title, :asc], [:text, :desc]] }
      end

    end

    it "and_return self" do
      @criteria.order_by.should == @criteria
    end

  end

  describe "#page" do

    context "when the page option exists" do

      before do
        @criteria.extras({ :page => 5 })
      end

      it "and_return the page option" do
        @criteria.page.should == 5
      end

    end

    context "when the page option does not exist" do

      it "returns 1" do
        @criteria.page.should == 1
      end

    end

  end

  describe "#paginate" do

    before do
      @collection = mock
      Person.should_receive(:collection).and_return(@collection)
      @criteria.select.where(:_id => "1").skip(60).limit(20)
      @cursor = mock('cursor', :count => 20, :to_a => [])
      @collection.should_receive(:find).with({:_id => "1"}, :skip => 60, :limit => 20).and_return(@cursor)
      @results = @criteria.paginate
    end

    it "executes and paginates the results" do
      @results.current_page.should == 4
      @results.per_page.should == 20
    end

  end

  describe "#per_page" do

    context "when the per_page option exists" do

      before do
        @criteria.extras({ :per_page => 10 })
      end

      it "and_return the per_page option" do
        @criteria.per_page.should == 10
      end

    end

    context "when the per_page option does not exist" do

      it "returns 1" do
        @criteria.per_page.should == 20
      end

    end

  end

  describe "#select" do

    context "when args are provided" do

      it "adds the options for limiting by fields" do
        @criteria.select(:title, :text)
        @criteria.options.should == { :fields => [ :title, :text ] }
      end

      it "and_return self" do
        @criteria.select.should == @criteria
      end

    end

    context "when no args provided" do

      it "does not add the field option" do
        @criteria.select
        @criteria.options[:fields].should be_nil
      end

    end

  end

  describe "#skip" do

    context "when value provided" do

      it "adds the skip value to the options" do
        @criteria.skip(20)
        @criteria.options.should == { :skip => 20 }
      end

    end

    context "when value not provided" do

      it "defaults to zero" do
        @criteria.skip
        @criteria.options.should == { :skip => 0 }
      end

    end

    it "and_return self" do
      @criteria.skip.should == @criteria
    end

  end

  describe ".translate" do

    context "with a single argument" do

      before do
        @id = Mongo::ObjectID.new.to_s
        @document = stub
        @criteria = mock
        MongoDoc::Criteria.should_receive(:new).and_return(@criteria)
        @criteria.should_receive(:id).with(@id).and_return(@criteria)
        @criteria.should_receive(:one).and_return(@document)
      end

      it "creates a criteria for a string" do
        MongoDoc::Criteria.translate(Person, @id)
      end

    end

    context "multiple arguments" do

      context "when Person, :conditions => {}" do

        before do
          @criteria = MongoDoc::Criteria.translate(Person, :conditions => { :title => "Test" })
        end

        it "and_return a criteria with a selector from the conditions" do
          @criteria.selector.should == { :title => "Test" }
        end

        it "and_return a criteria with klass Person" do
          @criteria.klass.should == Person
        end

      end

      context "when :all, :conditions => {}" do

        before do
          @criteria = MongoDoc::Criteria.translate(Person, :conditions => { :title => "Test" })
        end

        it "and_return a criteria with a selector from the conditions" do
          @criteria.selector.should == { :title => "Test" }
        end

        it "and_return a criteria with klass Person" do
          @criteria.klass.should == Person
        end

      end

      context "when :last, :conditions => {}" do

        before do
          @criteria = MongoDoc::Criteria.translate(Person, :conditions => { :title => "Test" })
        end

        it "and_return a criteria with a selector from the conditions" do
          @criteria.selector.should == { :title => "Test" }
        end

        it "and_return a criteria with klass Person" do
          @criteria.klass.should == Person
        end
      end

      context "when options are provided" do

        before do
          @criteria = MongoDoc::Criteria.translate(Person, :conditions => { :title => "Test" }, :skip => 10)
        end

        it "adds the criteria and the options" do
          @criteria.selector.should == { :title => "Test" }
          @criteria.options.should == { :skip => 10 }
        end
      end
    end
  end

  describe "#where" do

    it "adds the clause to the selector" do
      @criteria.where(:title => "Title", :text => "Text")
      @criteria.selector.should == { :title => "Title", :text => "Text" }
    end

    it "accepts a js where clause" do
      @criteria.where("this.a > 3")
      @criteria.selector.should == { '$where' => "this.a > 3" }
    end

    it "and return self" do
      @criteria.where.should == @criteria
    end

    it "#and is an alias for where" do
      @criteria.and(:title => "Title", :text => "Text")
      @criteria.selector.should == { :title => "Title", :text => "Text" }
    end

    it "#conditions is an alias for where" do
      @criteria.conditions(:title => "Title", :text => "Text")
      @criteria.selector.should == { :title => "Title", :text => "Text" }
    end
  end
end
