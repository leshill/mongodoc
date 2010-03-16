module MongoDoc
  module Contexts
    class Mongo
      include Mongoid::Contexts::Paging
      include Mongoid::Contexts::Ids

      attr_reader :criteria, :cache

      delegate :klass, :options, :selector, :to => :criteria
      delegate :collection, :to => :klass

      AGGREGATE_REDUCE = "function(obj, prev) { prev.count++; }"
      # Aggregate the context. This will take the internally built selector and options
      # and pass them on to the Ruby driver's +group()+ method on the collection. The
      # collection itself will be retrieved from the class provided, and once the
      # query has returned it will provided a grouping of keys with counts.
      #
      # Example:
      #
      # <tt>context.aggregate</tt>
      #
      # Returns:
      #
      # A +Hash+ with field values as keys, counts as values
      def aggregate
        collection.group(options[:fields], selector, { :count => 0 }, AGGREGATE_REDUCE, true)
      end

      # Get the average value for the supplied field.
      #
      # This will take the internally built selector and options
      # and pass them on to the Ruby driver's +group()+ method on the collection. The
      # collection itself will be retrieved from the class provided, and once the
      # query has returned it will provided a grouping of keys with averages.
      #
      # Example:
      #
      # <tt>context.avg(:age)</tt>
      #
      # Returns:
      #
      # A numeric value that is the average.
      def avg(field)
        total = sum(field)
        total ? (total / count) : nil
      end

      # Get the count of matching documents in the database for the context.
      #
      # Example:
      #
      # <tt>context.count</tt>
      #
      # Returns:
      #
      # An +Integer+ count of documents.
      def count
        @count ||= collection.find(selector, options).count
      end

      # Gets an array of distinct values for the supplied field across the
      # entire collection or the susbset given the criteria.
      #
      # Example:
      #
      # <tt>context.distinct(:title)</tt>
      def distinct(field)
        collection.distinct(field, selector)
      end

      # Determine if the context is empty or blank given the criteria. Will
      # perform a quick find_one asking only for the id.
      #
      # Example:
      #
      # <tt>context.blank?</tt>
      def empty?
        collection.find_one(selector, options).nil?
      end
      alias blank? empty?

      # Execute the context. This will take the selector and options
      # and pass them on to the Ruby driver's +find()+ method on the collection. The
      # collection itself will be retrieved from the class provided, and once the
      # query has returned new documents of the type of class provided will be instantiated.
      #
      # Example:
      #
      # <tt>mongo.execute</tt>
      #
      # Returns:
      #
      # An enumerable +Cursor+.
      def execute(paginating = false)
        cursor = collection.find(selector, options)
        if cursor
          @count = cursor.count if paginating
          cursor
        else
          []
        end
      end

      GROUP_REDUCE = "function(obj, prev) { prev.group.push(obj); }"
      # Groups the context. This will take the internally built selector and options
      # and pass them on to the Ruby driver's +group()+ method on the collection. The
      # collection itself will be retrieved from the class provided, and once the
      # query has returned it will provided a grouping of keys with objects.
      #
      # Example:
      #
      # <tt>context.group</tt>
      #
      # Returns:
      #
      # A +Hash+ with field values as keys, arrays of documents as values.
      def group
        collection.group(
          options[:fields],
          selector,
          { :group => [] },
          GROUP_REDUCE,
          true
        ).collect {|docs| docs["group"] = MongoDoc::BSON.decode(docs["group"]); docs }
      end

      # Create the new mongo context. This will execute the queries given the
      # selector and options against the database.
      #
      # Example:
      #
      # <tt>Mongoid::Contexts::Mongo.new(criteria)</tt>
      def initialize(criteria)
        @criteria = criteria
      end

      # Iterate over each +Document+ in the results. This can take an optional
      # block to pass to each argument in the results.
      #
      # Example:
      #
      # <tt>context.iterate { |doc| p doc }</tt>
      def iterate(&block)
        return caching(&block) if criteria.cached?
        if block_given?
          execute.each do |doc|
            yield doc
          end
        end
      end

      # Return the last result for the +Context+. Essentially does a find_one on
      # the collection with the sorting reversed. If no sorting parameters have
      # been provided it will default to ids.
      #
      # Example:
      #
      # <tt>context.last</tt>
      #
      # Returns:
      #
      # The last document in the collection.
      def last
        sorting = options[:sort] || [[:_id, :asc]]
        options[:sort] = sorting.collect { |option| [ option[0], option[1].invert ] }
        collection.find_one(selector, options)
      end

      MAX_REDUCE = "function(obj, prev) { if (prev.max == 'start') { prev.max = obj.[field]; } " +
        "if (prev.max < obj.[field]) { prev.max = obj.[field]; } }"
      # Return the max value for a field.
      #
      # This will take the internally built selector and options
      # and pass them on to the Ruby driver's +group()+ method on the collection. The
      # collection itself will be retrieved from the class provided, and once the
      # query has returned it will provided a grouping of keys with sums.
      #
      # Example:
      #
      # <tt>context.max(:age)</tt>
      #
      # Returns:
      #
      # A numeric max value.
      def max(field)
        grouped(:max, field.to_s, MAX_REDUCE)
      end

      MIN_REDUCE = "function(obj, prev) { if (prev.min == 'start') { prev.min = obj.[field]; } " +
        "if (prev.min > obj.[field]) { prev.min = obj.[field]; } }"
      # Return the min value for a field.
      #
      # This will take the internally built selector and options
      # and pass them on to the Ruby driver's +group()+ method on the collection. The
      # collection itself will be retrieved from the class provided, and once the
      # query has returned it will provided a grouping of keys with sums.
      #
      # Example:
      #
      # <tt>context.min(:age)</tt>
      #
      # Returns:
      #
      # A numeric minimum value.
      def min(field)
        grouped(:min, field.to_s, MIN_REDUCE)
      end

      # Return the first result for the +Context+.
      #
      # Example:
      #
      # <tt>context.one</tt>
      #
      # Return:
      #
      # The first document in the collection.
      def one
        collection.find_one(selector, options)
      end

      alias :first :one

      SUM_REDUCE = "function(obj, prev) { if (prev.sum == 'start') { prev.sum = 0; } prev.sum += obj.[field]; }"
      # Sum the context.
      #
      # This will take the internally built selector and options
      # and pass them on to the Ruby driver's +group()+ method on the collection. The
      # collection itself will be retrieved from the class provided, and once the
      # query has returned it will provided a grouping of keys with sums.
      #
      # Example:
      #
      # <tt>context.sum(:age)</tt>
      #
      # Returns:
      #
      # A numeric value that is the sum.
      def sum(field)
        grouped(:sum, field.to_s, SUM_REDUCE)
      end

      # Common functionality for grouping operations. Currently used by min, max
      # and sum. Will gsub the field name in the supplied reduce function.
      def grouped(start, field, reduce)
        result = collection.group(
          nil,
          selector,
          { start => "start" },
          reduce.gsub("[field]", field),
          true
        )
        result.empty? ? nil : result.first[start.to_s]
      end

      protected

      # Iterate and cache results from execute
      def caching(&block)
        if cache
          cache.each(&block)
        else
          @cache = []
          execute.each do |doc|
            @cache << doc
            yield doc if block_given?
          end
        end
      end
    end
  end
end
