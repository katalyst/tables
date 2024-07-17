# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query
        class SingleValueParser < ValueParser
          def initialize(...)
            super

            @value = nil
          end

          # @param query [StringScanner]
          def parse(query)
            @query = query

            @value_start = query.charpos

            take_quoted_value || take_unquoted_value

            @end = query.charpos

            self
          end

          def value
            @value
          end

          def value=(value)
            @value = value
          end

          def value_at(position)
            @value if (@value_start..@end).cover?(position)
          end
        end
      end
    end
  end
end
