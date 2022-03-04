# frozen_string_literal: true

module Katalyst
  module Tables
    module Backend
      # A FormObject (model) representing the sort state of controller for a given
      # collection/parameter.
      class SortForm
        DIRECTIONS = %w[asc desc].freeze

        attr_accessor :column, :direction

        def initialize(controller, column: nil, direction: nil)
          self.column    = column
          self.direction = direction

          @controller = controller
        end

        # Returns true if the given collection supports sorting on the given
        # column. A column supports sorting if it is a database column or if
        # the collection responds to `order_by_#{column}(direction)`.
        #
        # @param collection [ActiveRecord::Relation]
        # @param column [String, Symbol]
        # @return [true, false]
        def supports?(collection, column)
          collection.respond_to?("order_by_#{column}") ||
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

        # Generates a url for applying/toggling sort for the given column.
        #
        # @param column [String, Symbol] the table column as defined in table_with
        # @return [String] URL for use as a link in a column header
        def url_for(column)
          direction = "asc"

          if column.to_s == self.column
            case self.direction
            when "asc"
              direction = "desc"
            when "desc"
              direction = "asc"
            end
          end

          @controller.url_for(sort: "#{column} #{direction}")
        end

        # Apply the constructed sort ordering to the collection.
        #
        # @param collection [ActiveRecord::Relation]
        # @return [Array(SortForm, ActiveRecord::Relation)]
        def apply(collection)
          return [self, collection] if column.nil?

          if collection.respond_to?("order_by_#{column}")
            collection = collection.reorder(nil).public_send("order_by_#{column}", direction.to_sym)
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
