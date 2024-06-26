# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query
        class ArrayValueParser < ValueParser
          # @param query [StringScanner]
          def parse(query)
            @query = query

            skip_whitespace

            if query.scan(/#{'\['}/)
              take_values
            else
              take_value
            end
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

            current = @parser.attributes[@attribute.name] || []
            @parser.attributes[@attribute.name] = current + [value]
          end
        end
      end
    end
  end
end
