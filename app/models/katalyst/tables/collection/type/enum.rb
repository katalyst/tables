# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Enum < Value
          include Helpers::Multiple

          def initialize(multiple: true, **)
            super
          end

          def type
            :enum
          end

          def examples_for(scope, attribute)
            _, model, column = model_and_column_for(scope, attribute)
            keys = model.defined_enums[column]&.keys

            if attribute.value_before_type_cast.present?
              keys.select { |key| key.include?(attribute.value_before_type_cast.last) }
            else
              keys
            end
          end
        end
      end
    end
  end
end
