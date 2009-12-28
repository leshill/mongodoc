# This awesomeness is taken from Mongoid, Thanks Durran!

module MongoDoc #:nodoc:
  # The +Criteria+ class is the core object needed in Mongoid to retrieve
  # objects from the database. It is a DSL that essentially sets up the
  # selector and options arguments that get passed on to a <tt>Mongo::Collection</tt>
  # in the Ruby driver. Each method on the +Criteria+ returns self to they
  # can be chained in order to create a readable criterion to be executed
  # against the database.
  #
  # Example setup:
  #
  # <tt>criteria = Criteria.new</tt>
  #
  # <tt>criteria.select(:field => "value").only(:field).skip(20).limit(20)</tt>
  #
  # <tt>criteria.execute</tt>
  class Criteria
    SORT_REVERSALS = {
      :asc => :desc,
      :ascending => :descending,
      :desc => :asc,
      :descending => :ascending
    }

    include Enumerable

    attr_reader :collection, :klass, :options, :selector

    # Create the new +Criteria+ object. This will initialize the selector
    # and options hashes, as well as the type of criteria.
    #
    # Options:
    #
    # klass: The class to execute on.
    def initialize(klass)
      @selector, @options, @klass = {}, {}, klass
    end

    # Returns true if the supplied +Enumerable+ or +Criteria+ is equal to the results
    # of this +Criteria+ or the criteria itself.
    #
    # This will force a database load when called if an enumerable is passed.
    #
    # Options:
    #
    # other: The other +Enumerable+ or +Criteria+ to compare to.
    def ==(other)
      case other
      when Criteria
        self.selector == other.selector && self.options == other.options
      when Enumerable
        @collection ||= execute
        return (collection == other)
      else
        return false
      end
    end

    AGGREGATE_REDUCE = "function(obj, prev) { prev.count++; }"
    # Aggregate the criteria. This will take the internally built selector and options
    # and pass them on to the Ruby driver's +group()+ method on the collection. The
    # collection itself will be retrieved from the class provided, and once the
    # query has returned it will provided a grouping of keys with counts.
    #
    # Example:
    #
    # <tt>criteria.select(:field1).where(:field1 => "Title").aggregate</tt>
    def aggregate
      klass.collection.group(options[:fields], selector, { :count => 0 }, AGGREGATE_REDUCE)
    end

    # Get all the matching documents in the database for the +Criteria+.
    #
    # Example:
    #
    # <tt>criteria.all</tt>
    #
    # Returns: <tt>Array</tt>
    def all
      collect
    end

    # Get the count of matching documents in the database for the +Criteria+.
    #
    # Example:
    #
    # <tt>criteria.count</tt>
    #
    # Returns: <tt>Integer</tt>
    def count
      @count ||= klass.collection.find(selector, options.dup).count
    end

    # Iterate over each +Document+ in the results and pass each document to the
    # block.
    #
    # Example:
    #
    # <tt>criteria.each { |doc| p doc }</tt>
    def each(&block)
      @collection ||= execute
      if block_given?
        @collection = collection.inject([]) do |container, item|
          container << item
          yield item
          container
        end
      end
      self
    end

    GROUP_REDUCE = "function(obj, prev) { prev.group.push(obj); }"
    # Groups the criteria. This will take the internally built selector and options
    # and pass them on to the Ruby driver's +group()+ method on the collection. The
    # collection itself will be retrieved from the class provided, and once the
    # query has returned it will provided a grouping of keys with objects.
    #
    # Example:
    #
    # <tt>criteria.select(:field1).where(:field1 => "Title").group</tt>
    def group
      klass.collection.group(
        options[:fields],
        selector,
        { :group => [] },
        GROUP_REDUCE
      ).collect {|docs| docs["group"] = MongoDoc::BSON.decode(docs["group"]); docs }
    end

    # Return the last result for the +Criteria+. Essentially does a find_one on
    # the collection with the sorting reversed. If no sorting parameters have
    # been provided it will default to ids.
    #
    # Example:
    #
    # <tt>Criteria.select(:name).where(:name = "Chrissy").last</tt>
    def last
      opts = options.dup
      sorting = opts[:sort]
      sorting = [[:_id, :asc]] unless sorting
      opts[:sort] = sorting.collect { |option| [ option.first, Criteria.invert(option.last) ] }
      klass.collection.find_one(selector, opts)
    end

    # Return the first result for the +Criteria+.
    #
    # Example:
    #
    # <tt>Criteria.select(:name).where(:name = "Chrissy").one</tt>
    def one
      klass.collection.find_one(selector, options.dup)
    end
    alias :first :one

    # Translate the supplied argument hash
    #
    # Options:
    #
    # criteria_conditions: Hash of criteria keys, and parameter values
    #
    # Example:
    #
    # <tt>criteria.translate(:where => { :field => "value"}, :limit => 20)</tt>
    #
    # Returns <tt>self</tt>
    def criteria(criteria_conditions = {})
      criteria_conditions.inject(self) do |criteria, (key, value)|
        criteria.send(key, value)
      end
    end

    # Adds a criterion to the +Criteria+ that specifies values that must all
    # be matched in order to return results. Similar to an "in" clause but the
    # underlying conditional logic is an "AND" and not an "OR". The MongoDB
    # conditional operator that will be used is "$all".
    #
    # Options:
    #
    # selections: A +Hash+ where the key is the field name and the value is an
    # +Array+ of values that must all match.
    #
    # Example:
    #
    # <tt>criteria.every(:field => ["value1", "value2"])</tt>
    #
    # <tt>criteria.every(:field1 => ["value1", "value2"], :field2 => ["value1"])</tt>
    #
    # Returns: <tt>self</tt>
    def every(selections = {})
      selections.each { |key, value| selector[key] = { "$all" => value } }; self
    end

    # Adds a criterion to the +Criteria+ that specifies values that are not allowed
    # to match any document in the database. The MongoDB conditional operator that
    # will be used is "$ne".
    #
    # Options:
    #
    # excludes: A +Hash+ where the key is the field name and the value is a
    # value that must not be equal to the corresponding field value in the database.
    #
    # Example:
    #
    # <tt>criteria.excludes(:field => "value1")</tt>
    #
    # <tt>criteria.excludes(:field1 => "value1", :field2 => "value1")</tt>
    #
    # Returns: <tt>self</tt>
    def excludes(exclusions = {})
      exclusions.each { |key, value| selector[key] = { "$ne" => value } }; self
    end

    # Adds a criterion to the +Criteria+ that specifies additional options
    # to be passed to the Ruby driver, in the exact format for the driver.
    #
    # Options:
    #
    # extras: A +Hash+ that gets set to the driver options.
    #
    # Example:
    #
    # <tt>criteria.extras(:limit => 20, :skip => 40)</tt>
    #
    # Returns: <tt>self</tt>
    def extras(extras)
      options.merge!(extras)
      filter_options
      self
    end

    # Adds a criterion to the +Criteria+ that specifies an id that must be matched.
    #
    # Options:
    #
    # id_or_object_id: A +String+ representation of a <tt>Mongo::ObjectID</tt>
    #
    # Example:
    #
    # <tt>criteria.id("4ab2bc4b8ad548971900005c")</tt>
    #
    # Returns: <tt>self</tt>
    def id(id_or_object_id)
      selector[:_id] = id_or_object_id; self
    end

    # Adds a criterion to the +Criteria+ that specifies values where any can
    # be matched in order to return results. This is similar to an SQL "IN"
    # clause. The MongoDB conditional operator that will be used is "$in".
    #
    # Options:
    #
    # inclusions: A +Hash+ where the key is the field name and the value is an
    # +Array+ of values that any can match.
    #
    # Example:
    #
    # <tt>criteria.in(:field => ["value1", "value2"])</tt>
    #
    # <tt>criteria.in(:field1 => ["value1", "value2"], :field2 => ["value1"])</tt>
    #
    # Returns: <tt>self</tt>
    def in(inclusions = {})
      inclusions.each { |key, value| selector[key] = { "$in" => value } }; self
    end

    # Adds a criterion to the +Criteria+ that specifies the maximum number of
    # results to return. This is mostly used in conjunction with <tt>skip()</tt>
    # to handle paginated results.
    #
    # Options:
    #
    # value: An +Integer+ specifying the max number of results. Defaults to 20.
    #
    # Example:
    #
    # <tt>criteria.limit(100)</tt>
    #
    # Returns: <tt>self</tt>
    def limit(value = 20)
      options[:limit] = value; self
    end

    # Adds a criterion to the +Criteria+ that specifies values where none
    # should match in order to return results. This is similar to an SQL "NOT IN"
    # clause. The MongoDB conditional operator that will be used is "$nin".
    #
    # Options:
    #
    # exclusions: A +Hash+ where the key is the field name and the value is an
    # +Array+ of values that none can match.
    #
    # Example:
    #
    # <tt>criteria.not_in(:field => ["value1", "value2"])</tt>
    #
    # <tt>criteria.not_in(:field1 => ["value1", "value2"], :field2 => ["value1"])</tt>
    #
    # Returns: <tt>self</tt>
    def not_in(exclusions)
      exclusions.each { |key, value| selector[key] = { "$nin" => value } }; self
    end

    # Returns the offset option. If a per_page option is in the list then it
    # will replace it with a skip parameter and return the same value. Defaults
    # to 20 if nothing was provided.
    def offset
      options[:skip]
    end

    # Adds a criterion to the +Criteria+ that specifies the sort order of
    # the returned documents in the database. Similar to a SQL "ORDER BY".
    #
    # Options:
    #
    # params: An +Array+ of [field, direction] sorting pairs.
    #
    # Example:
    #
    # <tt>criteria.order_by([[:field1, :asc], [:field2, :desc]])</tt>
    #
    # Returns: <tt>self</tt>
    def order_by(params = [])
      options[:sort] = params; self
    end

    # Either returns the page option and removes it from the options, or
    # returns a default value of 1.
    def page
      if options[:skip] && options[:limit]
        (options[:skip].to_i + options[:limit].to_i) / options[:limit].to_i
      else
        1
      end
    end

    # Executes the +Criteria+ and paginates the results.
    #
    # Example:
    #
    # <tt>criteria.paginate</tt>
    def paginate
      @collection ||= execute
      WillPaginate::Collection.create(page, per_page, count) do |pager|
        pager.replace(collection.to_a)
      end
    end

    # Returns the number of results per page or the default of 20.
    def per_page
      (options[:limit] || 20).to_i
    end

    # Adds a criterion to the +Criteria+ that specifies the fields that will
    # get returned from the Document. Used mainly for list views that do not
    # require all fields to be present. This is similar to SQL "SELECT" values.
    #
    # Options:
    #
    # args: A list of field names to retrict the returned fields to.
    #
    # Example:
    #
    # <tt>criteria.select(:field1, :field2, :field3)</tt>
    #
    # Returns: <tt>self</tt>
    def select(*args)
      options[:fields] = args.flatten if args.any?; self
    end

    # Adds a criterion to the +Criteria+ that specifies how many results to skip
    # when returning Documents. This is mostly used in conjunction with
    # <tt>limit()</tt> to handle paginated results, and is similar to the
    # traditional "offset" parameter.
    #
    # Options:
    #
    # value: An +Integer+ specifying the number of results to skip. Defaults to 0.
    #
    # Example:
    #
    # <tt>criteria.skip(20)</tt>
    #
    # Returns: <tt>self</tt>
    def skip(value = 0)
      options[:skip] = value; self
    end

    # Adds a criterion to the +Criteria+ that specifies values that must
    # be matched in order to return results. This is similar to a SQL "WHERE"
    # clause. This is the actual selector that will be provided to MongoDB,
    # similar to the Javascript object that is used when performing a find()
    # in the MongoDB console.
    #
    # Options:
    #
    # selector_or_js: A +Hash+ that must match the attributes of the +Document+
    # or a +String+ of js code.
    #
    # Example:
    #
    # <tt>criteria.where(:field1 => "value1", :field2 => 15)</tt>
    #
    # <tt>criteria.where('this.a > 3')</tt>
    #
    # Returns: <tt>self</tt>
    def where(selector_or_js = {})
      case selector_or_js
      when String
        selector['$where'] = selector_or_js
      else
        selector.merge!(selector_or_js)
      end
      self
    end
    alias :and :where
    alias :conditions :where

    # Translate the supplied arguments into a +Criteria+ object.
    #
    # If the passed in args is a single +String+, then it will
    # construct an id +Criteria+ from it.
    #
    # If the passed in args are a type and a hash, then it will construct
    # the +Criteria+ with the proper selector, options, and type.
    #
    # Options:
    #
    # args: either a +String+ or a +Symbol+, +Hash combination.
    #
    # Example:
    #
    # <tt>Criteria.translate(Person, "4ab2bc4b8ad548971900005c")</tt>
    #
    # <tt>Criteria.translate(Person, :conditions => { :field => "value"}, :limit => 20)</tt>
    #
    # Returns a new +Criteria+ object.
    def self.translate(klass, params = {})
      return new(klass).id(params).one unless params.is_a?(Hash)
      return new(klass).criteria(params)
    end

    protected
    # Execute the criteria. This will take the internally built selector and options
    # and pass them on to the Ruby driver's +find()+ method on the collection. The
    # collection itself will be retrieved from the class provided.
    #
    # Returns either a cursor or an empty array.
    def execute
      cursor = klass.collection.find(selector, options.dup)
      if cursor
        @count = cursor.count
        cursor
      else
        []
      end
    end

    # Filters the unused options out of the options +Hash+. Currently this
    # takes into account the "page" and "per_page" options that would be passed
    # in if using will_paginate.
    def filter_options
      page_num = options.delete(:page)
      per_page_num = options.delete(:per_page)
      if (page_num || per_page_num)
        options[:limit] = (per_page_num || 20).to_i
        options[:skip] = (page_num || 1).to_i * options[:limit] - options[:limit]
      end
    end

    def self.invert(order)
      SORT_REVERSALS[order]
    end
  end
end