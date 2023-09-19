# frozen_string_literal: true

require "rack/request"

module Test
  HTML_ATTRIBUTES = {
    id:    "ID",
    class: "CLASS",
    html:  { style: "style" },
    data:  { foo: "bar" },
    aria:  { label: "LABEL" },
  }.freeze

  class Template
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include Katalyst::Tables::Frontend
    include ViewComponent::TestHelpers

    def translate(_key, default:)
      default
    end

    alias controller vc_test_controller
    alias render render_inline
    alias request vc_test_request
  end
end
