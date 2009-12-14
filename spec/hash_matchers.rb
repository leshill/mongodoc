class HasEntry
  def initialize(expected)
    @expected = expected
  end

  def matches?(target)
    @target = target
    @expected.all? do |key, value|
      @target[key] == value
    end
  end

  def failure_message_for_should
    "expected #{@target.inspect} to have entries #{@expected.inspect}"
  end

  def failure_message_for_should_not
    "expected #{@target.inspect} not to have entries #{@expected.inspect}"
  end
end

module HashMatchers
  def has_entry(expected)
    HasEntry.new(expected)
  end
  alias :has_entries :has_entry
end
