# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query
        class Parser # :nodoc:
          # query [StringScanner]
          attr_accessor :query
          attr_reader :collection, :untagged

          def initialize(collection)
            @collection = collection
            @untagged   = []
          end

          # @param query [String]
          def parse(query)
            @query = StringScanner.new(query)

            until @query.eos?
              skip_whitespace

              # break to ensure we don't loop indefinitely on bad input
              break unless take_tagged || take_untagged
            end

            if untagged.any? && (search = collection.class.search_attribute)
              collection.assign_attributes(search => untagged.join(" "))
            end

            self
          end

          private

          def skip_whitespace
            query.scan(/\s+/)
          end

          def take_tagged
            return unless query.scan(/(\w+(\.\w+)?):/)

            key, = query.values_at(1)
            skip_whitespace

            parser_for(key).parse(query)
          end

          def take_untagged
            return unless query.scan(/\S+/)

            untagged << query.matched

            untagged
          end

          using Type::Helpers::Extensions

          def parser_for(key)
            attribute = collection.class._default_attributes[key]

            if attribute.type.multiple? || attribute.value.is_a?(::Array)
              ArrayValueParser.new(collection:, attribute:)
            else
              SingleValueParser.new(collection:, attribute:)
            end
          end
        end
      end
    end
  end
end
