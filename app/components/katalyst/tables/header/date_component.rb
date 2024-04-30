# frozen_string_literal: true

using Katalyst::HtmlAttributes::HasHtmlAttributes

module Katalyst
  module Tables
    module Header
      class DateComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-date")
        end
      end
    end
  end
end
