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

            take_quoted_value || take_unquoted_value

            @end = query.charpos

            self
          end

          def value=(value)
            return if @attribute.type_cast(value).nil? # undefined attribute

            @matched = true
            @value = value
          end
        end
      end
    end
  end
end
