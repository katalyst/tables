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

          def filter(scope, attribute, value: filter_value(attribute))
            return scope unless filter?(attribute, value)

            if self.scope.present?
              scope.public_send(self.scope, value)
            elsif attribute.name.include?(".")
              table_name, = attribute.name.split(".")
              association = scope.model.reflections[table_name]

              raise(ArgumentError, "Unknown association '#{table_name}' for #{scope.model}") unless association

              apply_filter(scope.joins(table_name.to_sym), association.klass, attribute, value)
            else
              apply_filter(scope, scope.model, attribute, value)
            end
          end

          def to_param(value)
            serialize(value)
          end

          def suggestions(scope, attribute, limit: 10, order: :asc)
            model = scope.model
            column = attribute.name

            if attribute.name.include?(".")
              table_name, column = attribute.name.split(".")
              model = scope.model.reflections[table_name].klass

              raise(ArgumentError, "Unknown association '#{table_name}' for #{scope.model}") unless model

              scope = scope.joins(table_name.to_sym)
            end

            unless model.attribute_types.has_key?(column)
              raise(ArgumentError, "Unknown column '#{column}' for #{model}. " \
                                   "Consider defining '#{attribute.name.parameterize.underscore}_suggestions'")
            end

            filter(scope, attribute)
              .group(attribute.name)
              .distinct
              .limit(limit)
              .reorder(attribute.name => order)
              .pluck(attribute.name)
              .map { |v| database_suggestion(attribute:, value: deserialize(v)) }
          end

          private

          def constant_suggestion(attribute:, value:)
            Tables::Suggestions::ConstantValue.new(name: attribute.name, type: attribute.type, value:)
          end

          def database_suggestion(attribute:, value:)
            Tables::Suggestions::DatabaseValue.new(name: attribute.name, type: attribute.type, value:)
          end

          def filter_value(attribute)
            attribute.value
          end

          def apply_filter(scope, _model, attribute, value)
            if value.nil?
              scope.none
            else
              scope.where(attribute.name => serialize(value))
            end
          end
        end
      end
    end
  end
end
