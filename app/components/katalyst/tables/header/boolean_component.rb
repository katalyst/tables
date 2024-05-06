# frozen_string_literal: true

module Katalyst
  module Tables
    module Header
      class BooleanComponent < HeaderCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def default_html_attributes
          { class: "type-boolean" }.merge_html(super)
        end
      end
    end
  end
end
