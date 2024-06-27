# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query
        class ArrayValueParser < ValueParser
          def initialize(...)
            super

            @value = []
          end

          # @param query [StringScanner]
          def parse(query)
            @query = query

            skip_whitespace

            if query.scan(/#{'\['}/)
              take_values
            else
              take_value
            end

            @end = query.charpos

            self
          end

          def take_values
            until query.eos?
              skip_whitespace
              break unless take_quoted_value || take_unquoted_value

              skip_whitespace
              break unless take_delimiter
            end

            skip_whitespace
            take_end_of_list
          end

          def take_value
            take_quoted_value || take_unquoted_value
          end

          def take_delimiter
            query.scan(/#{','}/)
          end

          def take_end_of_list
            query.scan(/#{']'}/)
          end

          def value=(value)
            return if @attribute.type_cast(value).nil? # undefined attribute

            @matched = true
            @value << value
          end
        end
      end
    end
  end
end
