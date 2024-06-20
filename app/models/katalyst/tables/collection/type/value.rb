# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Value < ActiveModel::Type::Value
          attr_reader :scope

          def initialize(scope: nil)
            super()

            @scope = scope
          end

          def filter?(attribute, value)
            value.present? || attribute.came_from_user?
          end

          def filter(collection, attribute)
            value = filter_value(attribute)

            return unless filter?(attribute, value)

            model, column = model_and_column_for(collection, attribute)
            condition = filter_condition(model, column, value)

            collection.items = collection.items.merge(condition)
          end

          private

          def filter_value(attribute)
            attribute.value
          end

          def filter_condition(model, column, value)
            if value.nil?
              model.none
            elsif scope
              model.public_send(scope, value)
            else
              model.where(column => value)
            end
          end

          def model_and_column_for(collection, attribute)
            if attribute.name.include?(".")
              table, column = attribute.name.split(".")
              collection.items = collection.items.joins(table.to_sym)
              [collection.items.reflections[table].klass, column]
            else
              [collection.model, attribute.name]
            end
          end
        end
      end
    end
  end
end
