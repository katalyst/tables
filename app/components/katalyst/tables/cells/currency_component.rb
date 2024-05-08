# frozen_string_literal: true

module Katalyst
  module Tables
    module Cells
      # Formats the value as a money value
      #
      # The value is expected to be in cents.
      # Adds a class to the cell to allow for custom styling
      class CurrencyComponent < CellComponent
        def initialize(options:, **)
          super(**)

          @options = options
        end

        def rendered_value
          value.present? ? number_to_currency(value / 100.0, @options) : ""
        end

        private

        def default_html_attributes
          { class: "type-currency" }
        end
      end
    end
  end
end
