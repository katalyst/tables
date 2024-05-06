# frozen_string_literal: true

module Katalyst
  module Tables
    module Body
      # Formats the value as a number
      #
      # Adds a class to the cell to allow for custom styling
      class NumberComponent < BodyCellComponent
        def rendered_value
          value.present? ? number_to_human(value) : ""
        end

        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def default_html_attributes
          { class: "type-number" }.merge_html(super)
        end
      end
    end
  end
end
