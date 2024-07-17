# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query
        class ValueParser
          attr_accessor :query, :key

          def initialize(key:, start:)
            @key = key
            @start = start
          end

          def literal?
            false
          end

          def tagged?
            true
          end

          def range
            @start..@end
          end

          def take_quoted_value
            return unless query.scan(/"([^"]*)"/)

            self.value, = query.values_at(1)
          end

          def take_unquoted_value
            # note, we allow unquoted values to begin with a " so that partial
            # inputs can be accepted
            return unless query.scan(/"?([^ \],]*)/)

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
