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
        table.send(:add_dom_ids)
      end

      def initialize(**attributes)
        super

        # ensure row components generate dom ids
        add_dom_ids
      end

      using Katalyst::HtmlAttributes::HasHtmlAttributes

      def id
        html_attributes[:id]
      end

      def html_attributes
        if (attributes = super).key?(:id)
          attributes
        else
          attributes.merge_html(id: default_id)
        end
      end

      private

      # Add dom ids to body rows
      def add_dom_ids
        body_row_component.include(BodyRow)
      end

      # Returns the default dom id for the table, uses the collection's
      # model name's route_key as a sensible default.
      def default_id
        collection.items.model_name.route_key
      end

      module BodyRow # :nodoc:
        def id
          html_attributes[:id]
        end

        def default_html_attributes
          if (attributes = super).key?(:id)
            attributes
          else
            attributes.merge_html(id: dom_id(@record))
          end
        end
      end
    end
  end
end
