# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Value < ActiveModel::Type::Value
          module Extensions
            refine(ActiveModel::Type::Value) do
              def default_value
                nil
              end

              def multiple?
                false
              end

              def filterable?
                false
              end
            end
          end

          using Extensions

          attr_reader :scope

          def initialize(scope: nil, filter: true)
            super()

            @scope = scope
            @filterable = filter
          end

          def filterable?
            @filterable
          end

          def filter?(attribute, value)
            filterable? && (value.present? || attribute.came_from_user?)
          end

          def filter(scope, attribute)
            value = filter_value(attribute)

            return scope unless filter?(attribute, value)

            scope, model, column = model_and_column_for(scope, attribute)
            condition            = filter_condition(model, column, value)

            scope.merge(condition)
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

          def model_and_column_for(scope, attribute)
            if attribute.name.include?(".")
              table, column = attribute.name.split(".")
              [scope.joins(table.to_sym), scope.model.reflections[table].klass, column]
            else
              [scope, scope.model, attribute.name]
            end
          end
        end
      end
    end
  end
end
