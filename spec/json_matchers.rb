module JsonMatchers
  class BeJsonEql
    def initialize(expected)
      @raw_expected = expected
      @expected = decode(expected, 'expected')
    end

    def matches?(target)
      @raw_target = target
      @target = decode(target, 'target')
      @target == @expected
    end

    def failure_message
      "expected\...#{@raw_target}\n" +
      "to be JSON code equivalent to\...#{@raw_expected}\n" +
      "Difference:\...#{@expected.diff(@target).inspect}"
    end

    def negative_failure_message
      "expected\...#{@raw_target}\n" +
      "to be JSON code different from\...#{@raw_expected}"
    end

    private

    def decode(s, which)
      JSON.parse(s, :create_additions => false)
    end
  end

  def be_json_eql(expected)
    BeJsonEql.new(expected)
  end
end
