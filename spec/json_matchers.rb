module JsonMatchers
  class BeJsonEql
    def initialize(expected)
      @expected = expected
    end

    def matches?(target)
      @target = target
      @target == @expected
    end

    def failure_message
      "expected\...#{@target.inspect}\n" +
      "to be JSON code equivalent to\...#{@expected.inspect}\n" +
      "Difference:\...#{@expected.diff(@target).inspect}"
    end

    def negative_failure_message
      "expected\...#{@target.inspect}\n" +
      "to be JSON code different from\...#{@expected.inspect}"
    end
  end

  def be_json_eql(expected)
    BeJsonEql.new(expected)
  end
end
