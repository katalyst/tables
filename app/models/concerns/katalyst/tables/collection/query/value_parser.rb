# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query
        class ValueParser
          attr_accessor :query

          def initialize(parser:, attribute:)
            @parser = parser
            @attribute = attribute
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
