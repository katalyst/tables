# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query # :nodoc:
        extend ActiveSupport::Concern

        include Filtering

        included do
          config_accessor :search_scope

          attribute :query, :string, default: ""
          attribute :search, :string, default: ""

          # Note: this is defined inline so that we can overwrite query=
          def query=(value)
            query = super

            parser = Parser.new(self).parse(query)

            if searchable? && parser.untagged.any?
              self.search = parser.untagged.join(" ")
            end

            query
          end
        end

        # Returns true if the collection supports untagged searching. This
        # requires config.search_scope to be set to the name of the scope to use
        # in the target record for untagged text searches. If not set, untagged
        # search terms will be silently ignored.
        #
        # @return [true, false]
        def searchable?
          config.search_scope.present?
        end
      end
    end
  end
end
