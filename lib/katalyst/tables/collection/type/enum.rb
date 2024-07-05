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

            keys.map { |key| example(key, describe_key(model, attribute.name, key)) }
          end

          private

          def describe_key(model, name, key)
            label = model.human_attribute_name(name).downcase
            value = model.human_attribute_name("#{name}.#{key}").downcase
            "#{model.model_name.human} #{label} is #{value}"
          end
        end
      end
    end
  end
end
