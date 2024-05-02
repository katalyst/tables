# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Body::LinkComponent do
  include Rails.application.routes.url_helpers

  subject(:cell) { described_class.new(table, record, :name, url: record) }

  let(:table) { Katalyst::TableComponent.new(collection: Resource.all, name: "table") }
  let(:record) { create(:resource) }

  before do
    record
  end

  it "renders column" do
    expect(render_inline(cell)).to match_html(<<~HTML)
      <td><a href="/resources/#{record.id}">#{record.name}</a></td>
    HTML
  end

  context "when given a block" do
    it "renders the block's value" do
      expect(render_inline(cell) { "BLOCK" }).to match_html(<<~HTML)
        <td><a href="/resources/1">BLOCK</a></td>
      HTML
    end

    it "allows block to access value" do
      expect(render_inline(cell) { |cell| cell.value.to_s }).to match_html(<<~HTML)
        <td><a href="/resources/#{record.id}">#{record.name}</a></td>
      HTML
    end
  end

  context "with html_options" do
    subject(:cell) { described_class.new(table, record, :name, url: record, **Test::HTML_ATTRIBUTES) }

    it "renders tag with html_options" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">
          <a href="/resources/#{record.id}">#{record.name}</a>
        </td>
      HTML
    end
  end
end
