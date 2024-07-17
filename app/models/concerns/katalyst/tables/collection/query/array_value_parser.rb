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
              @value_start = query.charpos
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

          def value
            @value.map(&:value)
          end

          def value=(value)
            @value << Value.new(value, @value_start, @query.charpos)
          end

          def value_at(position)
            @value.detect { |v| v.range.cover?(position) }&.value
          end

          class Value
            attr_accessor :range, :value

            def initialize(value, start, fin)
              @value = value
              @range = (start..fin)
            end
          end
        end
      end
    end
  end
end
