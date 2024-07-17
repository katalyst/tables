# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query
        class UntaggedLiteral
          attr_accessor :query, :value

          def initialize(value:, start:)
            @value = value
            @start = start
            @end = start + value.length
          end

          def literal?
            true
          end

          def tagged?
            false
          end

          def range
            @start..@end
          end

          def to_str
            @value
          end
          alias to_s to_str
        end
      end
    end
  end
end
