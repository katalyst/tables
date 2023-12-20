# frozen_string_literal: true

module Katalyst
  module Tables
    module Backend
      # A FormObject (model) representing the sort state of controller for a given
      # collection/parameter.
      class SortForm
        DIRECTIONS = %w[asc desc].freeze

        attr_accessor :column, :direction, :default

        def self.parse(param, default: nil)
          column, direction = param.to_s.split
          direction         = "asc" unless DIRECTIONS.include?(direction)

          default = SortForm.parse(default).to_param if default.present?

          SortForm.new(column: column, direction: direction, default: default)
        end

        def initialize(column: nil, direction: nil, default: nil)
          self.column    = column
          self.direction = direction
          self.default   = default
        end

        def to_param
          "#{column} #{direction}"
        end

        # Returns true if the given collection supports sorting on the given
        # column. A column supports sorting if it is a database column or if
        # the collection responds to `order_by_#{column}(direction)`.
        #
        # @param collection [ActiveRecord::Relation]
        # @param column [String, Symbol]
        # @return [true, false]
        def supports?(collection, column)
          collection.respond_to?(:"order_by_#{column}") ||
            collection.model.has_attribute?(column.to_s)
        end

        # Returns the current sort behaviour of the given column, for use as a
        # column heading class in the table view.
        #
        # @param column [String, Symbol] the table column as defined in table_with
        # @return [String] the current sort behaviour of the given column
        def status(column)
          direction if column.to_s == self.column
        end

        # Calculates the sort parameter to apply when the given column is toggled.
        #
        # @param column [String, Symbol]
        # @return [String]
        def toggle(column)
          return "#{column} asc" unless column.to_s == self.column

          case direction
          when "asc"
            "#{column} desc"
          when "desc"
            "#{column} asc"
          end
        end

        # Apply the constructed sort ordering to the collection.
        #
        # @param collection [ActiveRecord::Relation]
        # @return [Array(SortForm, ActiveRecord::Relation)]
        def apply(collection)
          return [self, collection] if column.nil?

          if collection.respond_to?(:"order_by_#{column}")
            collection = collection.reorder(nil).public_send(:"order_by_#{column}", direction.to_sym)
          elsif collection.model.has_attribute?(column)
            collection = collection.reorder(column => direction)
          else
            clear!
          end

          [self, collection]
        end

        private

        def clear!
          self.column = self.direction = nil
        end
      end
    end
  end
end
