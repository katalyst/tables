# frozen_string_literal: true

module Katalyst
  module Tables
    module Cells
      # Formats the value as a number
      #
      # Adds a class to the cell to allow for custom styling
      class NumberComponent < CellComponent
        def rendered_value
          value.present? ? number_to_human(value) : ""
        end

        private

        def default_html_attributes
          { class: "type-number" }
        end
      end
    end
  end
end
