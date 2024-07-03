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
              keys = keys.select { |key| key.include?(attribute.value_before_type_cast.last) }
            end

            keys.map { |key| example(key, describe_key(model, attribute.name, key)) }
          end

          private

          def describe_key(model, attribute, key)
            key = I18n.t("active_record.attributes.#{model.model_name.i18n_key}/#{key}", default: key.to_s.titleize)
            "#{model.model_name.human} #{model.human_attribute_name(attribute).downcase} is #{key}"
          end
        end
      end
    end
  end
end
