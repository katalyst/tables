# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      using HasParams

      module Filtering # :nodoc:
        def filter
          # no-op by default
        end

        def filtered?
          filters.any?
        end

        def filters
          changed_attributes.except("sort", "page")
        end
      end
    end
  end
end
