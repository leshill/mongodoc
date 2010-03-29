module MongoDoc
  module DocumentTree

    attr_reader :_root

    %w(_modifier_path _selector_path).each do |getter|
      module_eval(<<-RUBY, __FILE__, __LINE__)
        def #{getter}
          @#{getter} ||= ''
        end
      RUBY
    end

    %w(_modifier_path _root _selector_path).each do |setter|
      module_eval(<<-RUBY, __FILE__, __LINE__)
        def #{setter}=(value)
          @#{setter} = value
          _associations.each do|a|
            association = send(a)
            association.#{setter} = value if association
          end
        end
      RUBY
    end
  end
end
