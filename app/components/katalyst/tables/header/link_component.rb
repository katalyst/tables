# frozen_string_literal: true

using Katalyst::HtmlAttributes::HasHtmlAttributes

module Katalyst
  module Tables
    module Header
      class LinkComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-link")
        end
      end
    end
  end
end
