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

          def suggestions(scope, attribute)
            _, model, column = model_and_column_for(scope, attribute)

            raise ArgumentError, "Unknown enum #{column} for #{model}" unless model.defined_enums.has_key?(column)

            values = model.defined_enums[column].keys

            if attribute.value_before_type_cast.present?
              values = values.select { |key| key.include?(attribute.value_before_type_cast) }
            end

            values.map { |value| constant_suggestion(attribute:, model:, column:, value:) }
          end

          private

          def cast_value(value)
            value.to_s
          end
        end
      end
    end
  end
end
