# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Boolean < Value
          include Helpers::Delegate
          include Helpers::Multiple

          def initialize(**)
            super(**, delegate: ActiveModel::Type::Boolean)
          end

          def filter?(attribute, value)
            return false unless filterable?

            if attribute.came_from_user?
              attribute.value_before_type_cast.present? || value === false
            else
              !value.nil? && !value.eql?([])
            end
          end

          def suggestions(scope, attribute)
            _, model, column = model_and_column_for(scope, attribute)

            values = %w[true false]

            if attribute.value_before_type_cast.present?
              values = values.select { |value| value.include?(attribute.value_before_type_cast) }
            end

            values.map { |v| constant_suggestion(attribute:, model:, column:, value: deserialize(v)) }
          end
        end
      end
    end
  end
end
