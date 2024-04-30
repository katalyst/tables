# frozen_string_literal: true

using Katalyst::HtmlAttributes::HasHtmlAttributes

module Katalyst
  module Tables
    module Header
      class CurrencyComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-currency")
        end
      end
    end
  end
end
