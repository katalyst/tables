# frozen_string_literal: true

module Katalyst
  module Tables
    module Body
      # Displays the plain text for rich text content
      #
      # Adds a title attribute to allow for hover over display of the full content
      class RichTextComponent < BodyCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def default_html_attributes
          { title: value.to_plain_text }.merge_html(super)
        end
      end
    end
  end
end
