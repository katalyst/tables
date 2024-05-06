# frozen_string_literal: true

module Katalyst
  module Tables
    module Header
      class DateComponent < HeaderCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def default_html_attributes
          { class: "type-date" }.merge_html(super)
        end
      end
    end
  end
end
