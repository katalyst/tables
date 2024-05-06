# frozen_string_literal: true

module Katalyst
  module Tables
    module Header
      class DateTimeComponent < HeaderCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def default_html_attributes
          { class: "type-datetime" }.merge_html(super)
        end
      end
    end
  end
end
