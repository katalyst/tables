# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Turbo::TableComponent do
  subject(:component) { described_class.new(collection:, id: "table") }

  let(:table) do
    with_request_url("/resources") do
      vc_test_request.headers["Accept"] = format
      render_inline(component) { |row| row.cell :name }
    end
  end
  let(:collection) { build(:collection, count: 1) }
  let(:format) { "text/html" }

  before do
    vc_test_controller.response = instance_double(ActionDispatch::Response, media_type: format)
  end

  it "creates a bare table" do
    expect(table).to match_html(<<~HTML)
      <table id="table" data-controller="tables--turbo--collection" data-tables--turbo--collection-query-value="">
        <thead><tr><th>Name</th></tr></thead>
        <tbody><tr><td>Person 1</td></tr></tbody>
      </table>
    HTML
  end

  context "with query params" do
    let(:collection) { build(:collection, sorting: "name", paginate: true, sort: "name desc", count: 1) }

    it "creates a bare table" do
      expect(table).to match_html(<<~HTML)
        <table id="table"
               data-controller="tables--turbo--collection"
               data-tables--turbo--collection-sort-value="name desc"
               data-tables--turbo--collection-query-value="sort=name+desc">
          <thead><tr><th data-sort="desc"><a data-turbo-stream="" href="/resources">Name</a></th></tr></thead>
          <tbody><tr><td>Person 1</td></tr></tbody>
        </table>
      HTML
    end
  end

  context "with query params matching defaults" do
    let(:collection) { build(:collection, sorting: "name", paginate: true, sort: "name asc", page: 1, count: 1) }

    it "creates a bare table" do
      expect(table).to match_html(<<~HTML)
        <table id="table"
               data-controller="tables--turbo--collection"
               data-tables--turbo--collection-sort-value="name asc"
               data-tables--turbo--collection-query-value="">
          <thead><tr><th data-sort="asc"><a data-turbo-stream="" href="/resources?sort=name+desc">Name</a></th></tr></thead>
          <tbody><tr><td>Person 1</td></tr></tbody>
        </table>
      HTML
    end
  end

  context "when a turbo-stream request" do
    let(:format) { "text/vnd.turbo-stream.html" }

    it "creates a turbo stream replace" do
      expect(table).to match_html(<<~HTML)
        <turbo-stream action="replace" target="table">
          <template>
            <table id="table" data-controller="tables--turbo--collection" data-tables--turbo--collection-query-value="">
              <thead><tr><th>Name</th></tr></thead>
              <tbody><tr><td>Person 1</td></tr></tbody>
            </table>
          </template>
        </turbo-stream>
      HTML
    end
  end
end
