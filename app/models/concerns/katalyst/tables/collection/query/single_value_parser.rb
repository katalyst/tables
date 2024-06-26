# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query
        class SingleValueParser < ValueParser
          # @param query [StringScanner]
          def parse(query)
            @query = query

            take_quoted_value || take_unquoted_value
          end

          def value=(value)
            return if @attribute.type_cast(value).nil? # undefined attribute

            @parser.attributes[@attribute.name] = value
          end
        end
      end
    end
  end
end
