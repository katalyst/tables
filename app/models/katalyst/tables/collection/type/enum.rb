# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Enum < Value
          def type
            :enum
          end

          def default_value
            []
          end

          def multiple?
            true
          end
        end
      end
    end
  end
end
