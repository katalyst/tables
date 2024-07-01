# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Query < Value
          def type
            :query
          end

          def filterable?
            false
          end
        end
      end
    end
  end
end
