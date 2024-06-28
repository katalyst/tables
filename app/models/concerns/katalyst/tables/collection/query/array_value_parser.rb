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

            query.scan(/#{'\['}\s*/)

            until query.eos?
              break unless take_quoted_value || take_unquoted_value
              break unless take_delimiter
            end

            query.scan(/\s*#{'\]'}?/)

            @end = query.charpos

            self
          end

          def take_delimiter
            query.scan(/\s*#{','}\s*/)
          end

          def value=(value)
            @value << value
          end
        end
      end
    end
  end
end
