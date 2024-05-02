# frozen_string_literal: true

using Katalyst::HtmlAttributes::HasHtmlAttributes

module Katalyst
  module Tables
    module Body
      # Displays the plain text for rich text content
      #
      # Adds a title attribute to allow for hover over display of the full content
      class RichTextComponent < BodyCellComponent
        def default_html_attributes
          { title: value.to_plain_text }
        end
      end
    end
  end
end
