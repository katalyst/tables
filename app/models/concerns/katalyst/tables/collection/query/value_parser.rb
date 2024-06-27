# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query
        class ValueParser
          attr_accessor :query, :value

          def initialize(attribute:, pos:)
            @attribute = attribute
            @start = pos
            @matched = false
          end

          def matched?
            @matched
          end

          def range
            @start..@end
          end

          def take_quoted_value
            return unless query.scan(/"([^"]*)"/)

            self.value, = query.values_at(1)
          end

          def take_unquoted_value
            return unless query.scan(/([^" \],]*)/)

            self.value, = query.values_at(1)
          end

          def skip_whitespace
            query.scan(/\s+/)
          end
        end
      end
    end
  end
end
