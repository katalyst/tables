# frozen_string_literal: true

module Test
  class Template
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include Katalyst::Tables::Frontend

    attr_accessor :output_buffer, :request, :controller

    def initialize(request:, controller:)
      @controller = controller
      @request    = request
    end

    def translate(_key, default:)
      default
    end
  end

  class Record
    def initialize(key:)
      @key = key
    end

    attr_accessor :key
  end

  class CustomTable < Katalyst::Tables::Frontend::TableBuilder
    def build(&block)
      @html_options = { class: "custom-table" }
      super
    end

    def table_header_row(builder = CustomHeaderRow, &block)
      super
    end

    def table_header_cell(method, builder = CustomHeaderCell, **options)
      super
    end

    def table_body_row(object, builder = CustomBodyRow, &block)
      super
    end

    def table_body_cell(object, method, builder = CustomBodyCell, **options, &block)
      super
    end

    class CustomHeaderRow < Katalyst::Tables::Frontend::Builder::HeaderRow
      def build
        options(class: "custom-header-row")
        super
      end
    end

    class CustomHeaderCell < Katalyst::Tables::Frontend::Builder::HeaderCell
      def build
        options(class: "custom-header-cell")
        super
      end
    end

    class CustomBodyRow < Katalyst::Tables::Frontend::Builder::BodyRow
      def build
        options(class: "custom-body-row")
        super
      end
    end

    class CustomBodyCell < Katalyst::Tables::Frontend::Builder::BodyCell
      def build
        options(class: "custom-body-cell")
        super
      end
    end
  end

  class ActionTable < Katalyst::Tables::Frontend::TableBuilder
    def build(&block)
      (@html_options[:class] ||= []) << "action-table"
      super
    end

    def table_header_row(builder = ActionHeaderRow, &block)
      super
    end

    def table_header_cell(method, builder = ActionHeaderCell, **options)
      super
    end

    def table_body_row(object, builder = ActionBodyRow, &block)
      super
    end

    def table_body_cell(object, method, builder = ActionBodyCell, **options, &block)
      super
    end

    class ActionHeaderRow < Katalyst::Tables::Frontend::Builder::HeaderRow
      def actions
        cell(:actions, class: "actions", label: "")
      end
    end

    class ActionHeaderCell < Katalyst::Tables::Frontend::Builder::HeaderCell
    end

    class ActionBodyRow < Katalyst::Tables::Frontend::Builder::BodyRow
      def actions(&block)
        cell(:actions, class: "actions", &block)
      end
    end

    class ActionBodyCell < Katalyst::Tables::Frontend::Builder::BodyCell
      def action(label, href, **opts)
        content_tag :a, label, { href: href }.merge(opts)
      end
    end
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
  before do
    rack = double(Rack::Utils)
    allow(rack).to receive(:build_nested_query) { |p| p.map { |k, v| "#{k}=#{v}" }.join("&") }
    stub_const("Rack::Utils", rack)
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
      id:    "ID",
      class: "CLASS",
      html:  { style: "style" },
      data:  { foo: "bar" }
    }
  end
  let(:table) do
    Katalyst::Tables::Frontend::TableBuilder.new(template, collection, object_name: :test_record)
  end

  include_context "with template"
end
