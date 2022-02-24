module Katalyst::Tables
  module Backend
    # A FormObject (model) representing the sort state of controller for a given
    # collection/parameter.
    class SortForm
      DIRECTIONS = %w[asc desc].freeze

      attr_accessor :column, :direction

      def initialize(controller, column: nil, direction: nil)
        self.column = column
        self.direction = direction

        @controller = controller
      end

      # Returns true if the given collection supports sorting on the given
      # column. A column supports sorting if it is a database column or if
      # the collection responds to `order_by_#{column}(direction)`.
      #
      # @param collection [ActiveRecord::Relation]
      # @param column [String|Symbol]
      def supports?(collection, column)
        collection.respond_to?("order_by_#{column}") ||
          collection.model.has_attribute?(column.to_s)
      end

      # Returns the current sort behaviour of the given column, for use as a
      # column heading class in the table view.
      #
      # @param column [String|Symbol] the table column as defined in table_with
      # @return [String] the current sort behaviour of the given column
      def status(column)
        direction if column.to_s == self.column
      end

      # Generates a url for applying/toggling sort for the given column.
      #
      # @param column [String|Symbol] the table column as defined in table_with
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
      # @param [ActiveRecord::Relation]
      # @return [[SortForm, ActiveRecord::Relation]]
      def apply(collection)
        if column.nil?
          [self, collection]
        elsif collection.respond_to?("order_by_#{column}")
          [self, collection.reorder(nil).public_send("order_by_#{column}", direction.to_sym)]
        elsif collection.model.has_attribute?(column)
          [self, collection.reorder(column => direction)]
        else
          self.column    = nil
          self.direction = nil
          [self, collection]
        end
      end
    end
  end
end
