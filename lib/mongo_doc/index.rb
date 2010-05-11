module MongoDoc
  module Index

    DIRECTION = { :asc => Mongo::ASCENDING,
      :desc => Mongo::DESCENDING,
      :geo2d => Mongo::GEO2D }
    OPTIONS = [:min, :max, :background, :unique, :dropDups]

    # Create an index on a collection.
    #
    # For compound indexes, pass pairs of fields and
    # directions (+:asc+, +:desc+) as a hash.
    #
    # For a unique index, pass the option +:unique => true+.
    # To create the index in the background, pass the options +:background => true+.
    # If you want to remove duplicates from existing records when creating the
    # unique index, pass the option +:dropDups => true+
    #
    # For GeoIndexing, specify the minimum and maximum longitude and latitude
    # values with the +:min+ and +:max+ options.
    #
    # <tt>Person.index(:last_name)</tt>
    # <tt>Person.index(:ssn, :unique => true)</tt>
    # <tt>Person.index(:first_name => :asc, :last_name => :asc)</tt>
    # <tt>Person.index(:first_name => :asc, :last_name => :asc, :unique => true)</tt>
    def index(*args)
      options_and_fields = args.extract_options!
      if args.any?
        collection.create_index(args.first, options_and_fields)
      else
        fields = options_and_fields.except(*OPTIONS)
        options = options_and_fields.slice(*OPTIONS)
        collection.create_index(to_mongo_direction(fields), options)
      end
    end

    protected
    def to_mongo_direction(fields_hash)
      fields_hash.to_a.map {|field| [field.first, direction(field.last)]}
    end

    def direction(dir)
      DIRECTION[dir] || Mongo::ASCENDING
    end
  end
end
