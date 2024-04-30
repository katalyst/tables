# frozen_string_literal: true

using Katalyst::HtmlAttributes::HasHtmlAttributes

module Katalyst
  module Tables
    module Body
      # Formats the value as a money value
      #
      # The value is expected to be in cents.
      # Adds a class to the cell to allow for custom styling
      class CurrencyComponent < BodyCellComponent
        def initialize(table, record, attribute, options: {}, **html_attributes)
          super(table, record, attribute, **html_attributes)

          @options = options
        end

        def rendered_value
          value.present? ? number_to_currency(value / 100.0, @options) : ""
        end

        def default_html_attributes
          super.merge_html(class: "type-currency")
        end
      end
    end
  end
end
