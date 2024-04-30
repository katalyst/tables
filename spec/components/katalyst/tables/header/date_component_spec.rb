# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Header::DateComponent do
  subject(:header) { described_class.new(table, :created_at) }

  let(:table) { Katalyst::TableComponent.new(collection: Person.all, id: "table") }
  let(:record) { create(:person) }
  let(:rendered) { render_inline(header) }

  before do
    record
  end

  it "renders column header" do
    expect(rendered).to match_html(<<~HTML)
      <th class="type-date">Created at</th>
    HTML
  end

  context "with html_options" do
    subject(:header) { described_class.new(table, :created_at, **Test::HTML_ATTRIBUTES) }

    it "renders tag with html_options" do
      expect(rendered).to match_html(<<~HTML)
        <th id="ID" class="type-date CLASS" style="style" data-foo="bar" aria-label="LABEL">Created at</th>
      HTML
    end
  end

  context "when given a label" do
    subject(:header) { described_class.new(table, :created_at, label: "LABEL") }

    it "renders the label" do
      expect(rendered).to match_html(<<~HTML)
        <th class="type-date">LABEL</th>
      HTML
    end
  end

  context "when given an empty label" do
    subject(:header) { described_class.new(table, :created_at, label: "") }

    it "renders an empty header" do
      expect(rendered).to match_html(<<~HTML)
        <th class="type-date"></th>
      HTML
    end
  end

  context "when given a block" do
    it "renders the default value" do
      # this behaviour is intentional – assumes block is for body rendering, not header
      expect(rendered { "BLOCK" }).to match_html(<<~HTML)
        <th class="type-date">Created at</th>
      HTML
    end
  end
end
