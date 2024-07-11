# frozen_string_literal: true

module Katalyst
  module Tables
    module Suggestions
      class Base
        attr_reader :value

        def initialize(value)
          @value = value
        end

        def type
          raise NotImplementedError
        end

        def hash
          [self.class, value].hash
        end

        def eql?(other)
          other.class.eql?(self.class) && other.value.eql?(value)
        end

        def inspect
          "#<#{self.class.name} value: #{value.inspect}>"
        end
      end
    end
  end
end
