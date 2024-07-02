# frozen_string_literal: true

module Katalyst
  module Tables
    # Adds checkbox selection to a table.
    # See [documentation](/docs/selectable.md) for more details.
    module Selectable
      extend ActiveSupport::Concern

      FORM_CONTROLLER = "tables--selection--form"
      TABLE_CONTROLLER = "tables--selection--table"
      ITEM_CONTROLLER = "tables--selection--item"

      # Returns the default dom id for the selection form, uses the table's
      # default id with '_selection' appended.
      def self.default_form_id(collection)
        "#{Identifiable::Defaults.default_table_id(collection)}_selection_form"
      end

      # Adds the selection column to the table
      #
      # @param params [Hash] params to pass to the controller for selected rows
      # @param form_id [String] id of the form element that will submit the selected row params
      # @param ** [Hash] HTML attributes to be added to column cells
      # @param & [Proc] optional block to alter the cell content
      # @return [void]
      #
      # @example Render a select column
      #   <% row.select %> # => <td><input type="checkbox" ...></td>
      def select(params: { id: record&.id }, form_id: Selectable.default_form_id(collection), **, &)
        update_html_attributes(**table_selection_attributes(form_id:)) if header?

        with_cell(Cells::SelectComponent.new(
                    collection:, row:, column: :_select, record:, label: "", heading: false, params:, form_id:, **,
                  ), &)
      end

      private

      def table_selection_attributes(form_id:)
        {
          data: {
            controller: TABLE_CONTROLLER,
            "#{TABLE_CONTROLLER}-#{FORM_CONTROLLER}-outlet" => "##{form_id}",
            action: ["#{ITEM_CONTROLLER}:select->#{TABLE_CONTROLLER}#update"],
          },
        }
      end
    end
  end
end
