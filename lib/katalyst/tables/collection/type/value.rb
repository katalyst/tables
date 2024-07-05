# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Value < ActiveModel::Type::Value
          using Helpers::Extensions

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
            return false unless filterable?

            if attribute.came_from_user?
              attribute.value_before_type_cast.present?
            else
              value.present?
            end
          end

          def filter(scope, attribute)
            value = filter_value(attribute)

            return scope unless filter?(attribute, value)

            scope, model, column = model_and_column_for(scope, attribute)
            condition = filter_condition(model, column, value)

            scope.merge(condition)
          end

          def to_param(value)
            serialize(value)
          end

          def examples_for(scope, attribute, limit: 10, order: :asc)
            scope, model, column = model_and_column_for(scope, attribute)

            unless model.attribute_types.has_key?(column)
              raise(ArgumentError, "Unknown column '#{column}' for #{model}. " \
                                   "Consider defining '#{attribute.name.parameterize.underscore}_examples'")
            end

            column = model.arel_table[column]

            filter(scope, attribute)
              .group(column)
              .distinct
              .limit(limit)
              .reorder(column => order)
              .pluck(column)
              .map { |v| example(deserialize(v)) }
          end

          private

          def example(value, description = "")
            Example.new(to_param(value), description)
          end

          def filter_value(attribute)
            attribute.value
          end

          def filter_condition(model, column, value)
            if value.nil?
              model.none
            elsif scope
              model.public_send(scope, value)
            else
              model.where(column => serialize(value))
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
