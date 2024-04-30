# frozen_string_literal: true

using Katalyst::HtmlAttributes::HasHtmlAttributes

module Katalyst
  module Tables
    module Header
      class BooleanComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-boolean")
        end
      end
    end
  end
end
