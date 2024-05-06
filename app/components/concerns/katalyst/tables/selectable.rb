# frozen_string_literal: true

module Katalyst
  module Tables
    # Adds checkbox selection to a table.
    # See [documentation](/docs/selectable.md) for more details.
    module Selectable
      extend ActiveSupport::Concern

      FORM_CONTROLLER = "tables--selection--form"
      ITEM_CONTROLLER = "tables--selection--item"

      # Adds the selection column to the table
      def select(params = { id: @current_record&.id }, **html_attributes)
        component = SelectComponent.new(self, @current_row, params, **html_attributes)

        cell(:_select, label: "", **component.html_attributes) do
          component.render_in(view_context)
        end
      end
    end
  end
end
