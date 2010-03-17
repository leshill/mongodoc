module MongoDoc
  module Index

    # Create an index on a collection. For a unique index, pass the unique
    # option +:unique => true+. For compound indexes, pass pairs of fields and
    # directions (+:asc+, +:desc+) as a hash.
    #
    # <tt>Person.index(:last_name)</tt>
    # <tt>Person.index(:ssn, :unique => true)</tt>
    # <tt>Person.index(:first_name => :asc, :last_name => :asc)</tt>
    # <tt>Person.index(:first_name => :asc, :last_name => :asc, :unique => true)</tt>
    def index(*args)
      options_and_fields = args.extract_options!
      unique = options_and_fields.delete(:unique) || false
      if args.any?
        collection.create_index(args.first, unique)
      else
        collection.create_index(to_mongo_direction(options_and_fields), unique)
      end
    end

    protected
    def to_mongo_direction(fields_hash)
      fields_hash.to_a.map {|field| [field.first, field.last == :desc ? Mongo::DESCENDING : Mongo::ASCENDING]}
    end
  end
end
