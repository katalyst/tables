# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Example
          attr_reader :value, :description

          def initialize(value, description = "")
            @value = value
            @description = description
          end

          def hash
            value.hash
          end

          def eql?(other)
            value.eql?(other.value)
          end

          def to_s
            value.to_s
          end
        end
      end
    end
  end
end
