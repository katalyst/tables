# frozen_string_literal: true

module Katalyst
  module Tables
    # Adds drag and drop ordering to a table.
    # See [documentation](/docs/orderable.md) for more details.
    module Orderable
      extend ActiveSupport::Concern

      FORM_CONTROLLER = "tables--orderable--form"
      ITEM_CONTROLLER = "tables--orderable--item"
      LIST_CONTROLLER = "tables--orderable--list"

      # Returns the default dom id for the selection form, uses the table's
      # default id with '_selection' appended.
      def self.default_form_id(collection)
        "#{Identifiable::Defaults.default_table_id(collection)}_order_form"
      end

      # Generate a form input 'name' for param updates for a given record and attribute.
      def self.default_scope(collection)
        "order[#{collection.model_name.plural}]"
      end

      # Generate a nested scope for for param updates for a given record and attribute.
      # Will be concatenated with the form's scope in the browser.
      def self.record_scope(id, attribute)
        "[#{id}][#{attribute}]"
      end

      # Generates a column for the user to drag and drop to reorder data rows.
      #
      # @param column [Symbol] the value to update when the user reorders the rows
      # @param primary_key [Symbol] key for identifying rows that have changed in params (:id by default)
      # @param ** [Hash] HTML attributes to be added to column cells
      # @param & [Proc] optional block to wrap the cell content
      # @return [void]
      #
      # @example Render a column with a drag-and-drop handle for users to reorder rows
      #   <% row.ordinal %> # label => <th></th>, data => <td ...>⠿</td>
      def ordinal(column = :ordinal, primary_key: :id, **, &)
        initialize_orderable if row.header?

        with_cell(Cells::OrdinalComponent.new(
                    collection:, row:, column:, record:, label: "", heading: false, primary_key:, **,
                  ), &)
      end

      private

      def initialize_orderable
        update_tbody_attributes(
          data: {
            controller: LIST_CONTROLLER,
            action: %W[mousedown->#{LIST_CONTROLLER}#mousedown
                       turbo:before-morph-element->#{LIST_CONTROLLER}#beforeMorphElement:self],
            "#{LIST_CONTROLLER}-#{FORM_CONTROLLER}-outlet" => "##{Orderable.default_form_id(collection)}",
            "#{LIST_CONTROLLER}-#{ITEM_CONTROLLER}-outlet" => "td.ordinal",
          },
        )
      end
    end
  end
end
