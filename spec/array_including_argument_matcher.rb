# From http://gist.github.com/62943
# Author http://github.com/trotter
module RSpec
  module Mocks
    module ArgumentMatchers

      class ArrayIncludingMatcher
        # We'll allow an array of arguments to be passed in, so that you can do
        # things like obj.should_receive(:blah).with(array_including('a', 'b'))
        def initialize(*expected)
          @expected = expected
        end

        # actual is the array (hopefully) passed to the method by the user.
        # We'll check that it includes all the expected values, and return false
        # if it doesn't or if we blow up because #include? is not defined.
        def ==(actual)
          @expected.each do |expected|
            return false unless actual.include?(expected)
          end
          true
        rescue NoMethodError => ex
          return false
        end

        def description
          "array_including(#{@expected.join(', ')})"
        end
      end

      class ArrayNotIncludingMatcher
        def initialize(*expected)
          @expected = expected
        end

        def ==(actual)
          @expected.each do |expected|
            return false if actual.include?(expected)
          end
          true
        rescue NoMethodError => ex
          return false
        end

        def description
          "array_not_including(#{@expected.join(', ')})"
        end
      end

      # array_including is a helpful wrapper that allows us to actually type
      # #with(array_including(...)) instead of ArrayIncludingMatcher.new(...)
      def array_including(*args)
        ArrayIncludingMatcher.new(*args)
      end

      def array_not_including(*args)
        ArrayNotIncludingMatcher.new(*args)
      end

    end
  end
end
