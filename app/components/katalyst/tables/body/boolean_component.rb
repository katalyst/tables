# frozen_string_literal: true

module Katalyst
  module Tables
    module Body
      # Shows Yes/No for boolean values
      class BooleanComponent < BodyCellComponent
        def rendered_value
          value ? "Yes" : "No"
        end
      end
    end
  end
end
