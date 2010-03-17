module MongoDoc
  module Index

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
