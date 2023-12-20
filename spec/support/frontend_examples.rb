# frozen_string_literal: true

require "rack/request"
require "rails_helper"

module Test
  HTML_ATTRIBUTES = {
    id:    "ID",
    class: "CLASS",
    html:  { style: "style" },
    data:  { foo: "bar" },
    aria:  { label: "LABEL" },
  }.freeze

  class Template
    include ActionView::Context

    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::FormHelper
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

    delegate_missing_to :controller
  end
end
