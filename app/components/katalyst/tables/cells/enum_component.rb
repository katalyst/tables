# frozen_string_literal: true

module Katalyst
  module Tables
    module Cells
      # Displays an enum value using data inferred from the model.
      class EnumComponent < CellComponent
        def rendered_value
          if (value = self.value).present?
            label = collection.model.human_attribute_name("#{column}.#{value}")
            content_tag(:small, label, data: { enum: column, value: })
          end
        end

        private

        def default_html_attributes
          { class: "type-enum" }
        end
      end
    end
  end
end
