# frozen_string_literal: true

using Katalyst::HtmlAttributes::HasHtmlAttributes

module Katalyst
  module Tables
    module Header
      class AttachmentComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-attachment")
        end
      end
    end
  end
end
