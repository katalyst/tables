module Katalyst::Tables
  module Backend
    class SortForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      DIRECTIONS = %w[asc desc].freeze

      attribute :column
      attribute :direction

      def initialize(controller, **attributes)
        super(**attributes)

        @controller = controller
      end

      def supports?(collection, column)
        collection.respond_to?("order_by_#{column}") || collection.model.has_attribute?(column)
      end

      def status(column)
        direction if column.to_s == self.column
      end

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

      def apply(collection)
        if collection.respond_to?("order_by_#{column}")
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
