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

            raise ArgumentError, "Unknown enum #{column} for #{model}" unless model.defined_enums.has_key?(column)

            keys = model.defined_enums[column].keys

            if attribute.value_before_type_cast.present?
              keys = keys.select { |key| key.include?(attribute.value_before_type_cast.last) }
            end

            keys.map { |key| example(key, describe_key(model, attribute, key)) }
          end

          private

          def cast_value(value)
            value.to_s
          end

          def describe_key(model, attribute, key)
            label = model.human_attribute_name(attribute.name).downcase
            value = model.human_attribute_name("#{attribute.name}.#{key}").downcase

            description = "#{model.model_name.human} #{label} is #{value}"
            description += " (default)" if default?(attribute, key)
            description
          end

          def default?(attribute, value)
            if multiple?
              attribute.original_value&.intersection(cast(value))&.any?
            else
              attribute.default_value.eql?(cast(value))
            end
          end
        end
      end
    end
  end
end
