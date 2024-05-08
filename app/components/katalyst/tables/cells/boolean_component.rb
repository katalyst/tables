# frozen_string_literal: true

module Katalyst
  module Tables
    module Cells
      # Shows Yes/No for boolean values
      class BooleanComponent < CellComponent
        def rendered_value
          value ? "Yes" : "No"
        end

        private

        def default_html_attributes
          { class: "type-boolean" }
        end
      end
    end
  end
end
