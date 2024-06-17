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
          changes.except("sort", "page").transform_values(&:second)
        end
      end
    end
  end
end
