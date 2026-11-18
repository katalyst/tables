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
            model  = scope.model
            column = attribute.name

            if attribute.name.include?(".")
              table_name, column = attribute.name.split(".")
              model              = scope.model.reflections[table_name].klass

              raise(ArgumentError, "Unknown association '#{table_name}' for #{scope.model}") unless model
            end

            raise ArgumentError, "Unknown enum #{column} for #{model}" unless model.defined_enums.has_key?(column)

            values = model.defined_enums[column].keys

            if attribute.value_before_type_cast.present?
              values = values.select { |key| key.to_s.include?(attribute.value_before_type_cast) }
            end

            values.map { |value| constant_suggestion(attribute:, value:) }
          end

          private

          def cast_value(value)
            value.to_s
          end

          # Active Record filters unknown enum values on IS NULL. Unknown values
          # can't match any row, so remove them, and match nothing if none remain.
          def apply_filter(scope, model, attribute, value)
            mapping = model.defined_enums[attribute.name.split(".").last]

            # not a Rails enum, leave it to the database
            return super if mapping.nil?

            known = known_values(mapping, Array(value))

            known.any? ? super(scope, model, attribute, known) : scope.none
          end

          # Accepts labels and database values, matching Active Record.
          def known_values(mapping, values)
            database_values = mapping.values.map(&:to_s)

            values.select { |v| mapping.key?(v) || database_values.include?(v) }
          end
        end
      end
    end
  end
end
