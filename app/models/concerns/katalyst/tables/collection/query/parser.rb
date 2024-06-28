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

          private

          def skip_whitespace
            query.scan(/\s+/)
          end

          def take_tagged
            start = query.charpos

            return unless query.scan(/(\w+(\.\w+)?):/)

            key, = query.values_at(1)
            skip_whitespace

            tagged[key] = value_parser(start).parse(query)
          end

          def take_untagged
            return unless query.scan(/\S+/)

            untagged << query.matched

            untagged
          end

          using Type::Helpers::Extensions

          def value_parser(start)
            if query.check(/#{'\['}\s*/)
              ArrayValueParser.new(start:)
            else
              SingleValueParser.new(start:)
            end

            # if attribute.type.multiple? || attribute.value.is_a?(::Array)
            #   ArrayValueParser.new(attribute:, pos:)
            # else
            #   SingleValueParser.new(attribute:, pos:)
            # end
          end
        end
      end
    end
  end
end
