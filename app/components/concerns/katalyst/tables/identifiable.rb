# frozen_string_literal: true

module Katalyst
  module Tables
    # Adds dom ids to the table and row components.
    # See [documentation](/docs/identifiable.md) for more details.
    module Identifiable
      extend ActiveSupport::Concern

      # Support for extending a table component instance
      # Adds methods to the table component instance
      def self.extended(table)
        # ensure row components generate dom ids
        table.send(:register_identifiable_callbacks)
      end

      def initialize(**attributes)
        super

        # ensure row components generate dom ids
        table.register_identifiable_callbacks
      end

      using Katalyst::HtmlAttributes::HasHtmlAttributes

      # Merge the default dom ID into the table when html_attributes is read.
      def html_attributes
        if (attributes = super).key?(:id)
          attributes
        else
          attributes.merge_html(id: default_id)
        end
      end

      private

      # Returns the default dom id for the table, uses the collection's
      # model name's route_key as a sensible default.
      def default_id
        collection.items.model_name.route_key
      end

      def register_identifiable_callbacks
        @body_row_callbacks << Proc.new do |row, record|
          row.update_html_attributes(id: dom_id(record))
        end
      end
    end
  end
end
