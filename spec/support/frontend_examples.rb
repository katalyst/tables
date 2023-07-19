# frozen_string_literal: true

module Test
  class Template
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include Katalyst::Tables::Frontend
    include ViewComponent::TestHelpers

    attr_accessor :output_buffer, :request, :controller

    def initialize(request:, controller:)
      @controller = controller
      @request    = request
    end

    def translate(_key, default:)
      default
    end

    alias render render_inline
  end

  class Record
    def initialize(key:)
      @key = key
    end

    attr_accessor :key
  end
end

RSpec.shared_context "with mocked request" do |path: "/resource", params: {}|
  let(:request) do
    require("rack/request")
    request = instance_double(Rack::Request)
    allow(request).to receive_messages(GET: params, path: path)
    request
  end
  let(:controller) do
    ApplicationController.new
  end
end

RSpec.shared_context "with template" do
  let(:template) { Test::Template.new(request: request, controller: controller) }

  include_context "with collection"
  include_context "with mocked request"
end

RSpec.shared_context "with table" do
  let(:html_options) do
    {
      id: "ID",
      class: "CLASS",
      html: { style: "style" },
      data: { foo: "bar" }
    }
  end
  let(:table) do
    Katalyst::TableComponent.new(collection: collection, object_name: :test_record)
  end

  include_context "with template"
end
