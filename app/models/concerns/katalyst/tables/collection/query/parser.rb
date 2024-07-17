# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query
        class Parser # :nodoc:
          # query [StringScanner]
          attr_accessor :query
          attr_reader :collection, :untagged, :tagged

          def initialize(collection)
            @collection = collection
            @tagged = {}
            @untagged = []
          end

          # @param query [String]
          def parse(query)
            @query = StringScanner.new(query)

            until @query.eos?
              skip_whitespace

              # break to ensure we don't loop indefinitely on bad input
              break unless take_tagged || take_untagged
            end

            self
          end

          def token_at_position(position:)
            tagged.values.detect { |v| v.range.cover?(position) } ||
              untagged.detect { |v| v.range.cover?(position) }
          end

          private

          def skip_whitespace
            query.scan(/\s+/)
          end

          def take_tagged
            start = query.charpos

            return unless query.scan(/(\w+(\.\w+)?):/)

            key, = query.values_at(1)
            skip_whitespace

            tagged[key] = value_parser(key, start).parse(query)
          end

          def take_untagged
            start = query.charpos

            return unless query.scan(/\S+/)

            untagged << UntaggedLiteral.new(value: query.matched, start:)

            untagged
          end

          using Type::Helpers::Extensions

          def value_parser(key, start)
            if query.check(/#{'\['}\s*/)
              ArrayValueParser.new(key:, start:)
            else
              SingleValueParser.new(key:, start:)
            end
          end
        end
      end
    end
  end
end
