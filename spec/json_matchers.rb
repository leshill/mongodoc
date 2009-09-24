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
      ignore_json_class_exec {JSON.parse(s)}
    rescue
      raise ArgumentError, "Invalid #{which} JSON string: #{s.inspect}"
    end
  end

  def be_json_eql(expected)
    BeJsonEql.new(expected)
  end
  
  module JsonCreatableSwitch
    module ClassMethods
      @@json_creatable = true
      
      def json_creatable?
        @@json_creatable
      end
    
      def json_creatable(value)
        @@json_creatable = value
      end
    
      def ignore_json_class_exec(&block)
        original = json_creatable?
        json_creatable(false)
        yield block
      ensure
        json_creatable(original)
      end
    end
    
    module InstanceMethods
      def ignore_json_class_exec(&block)
        self.class.ignore_json_class_exec(&block)
      end
    end
  end
end

Object.extend(JsonMatchers::JsonCreatableSwitch::ClassMethods)
Object.send(:include, JsonMatchers::JsonCreatableSwitch::InstanceMethods)