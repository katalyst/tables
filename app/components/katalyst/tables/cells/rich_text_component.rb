# frozen_string_literal: true

module Katalyst
  module Tables
    module Cells
      # Displays the plain text for rich text content
      #
      # Adds a title attribute to allow for hover over display of the full content
      class RichTextComponent < CellComponent
        private

        def default_html_attributes
          {
            data:  { cell_type: "rich-text" },
            title: (value.to_plain_text unless row.header?),
          }
        end
      end
    end
  end
end
