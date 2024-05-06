# frozen_string_literal: true

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

        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def default_html_attributes
          { class: "type-currency" }.merge_html(super)
        end
      end
    end
  end
end
