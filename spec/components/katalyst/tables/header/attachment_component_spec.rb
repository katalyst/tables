# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Header::AttachmentComponent do
  subject(:header) { described_class.new(table, :image) }

  let(:table) { Katalyst::TableComponent.new(collection: Resource.all, id: "table") }
  let(:record) { create(:resource, :with_image) }
  let(:rendered) { render_inline(header) }

  before do
    record
  end

  it "renders column header" do
    expect(rendered).to match_html(<<~HTML)
      <th class="type-attachment">Image</th>
    HTML
  end

  context "with html_options" do
    subject(:header) { described_class.new(table, :image, **Test::HTML_ATTRIBUTES) }

    it "renders tag with html_options" do
      expect(rendered).to match_html(<<~HTML)
        <th id="ID" class="type-attachment CLASS" style="style" data-foo="bar" aria-label="LABEL">Image</th>
      HTML
    end
  end

  context "when given a label" do
    subject(:header) { described_class.new(table, :image, label: "LABEL") }

    it "renders the label" do
      expect(rendered).to match_html(<<~HTML)
        <th class="type-attachment">LABEL</th>
      HTML
    end
  end

  context "when given an empty label" do
    subject(:header) { described_class.new(table, :image, label: "") }

    it "renders an empty header" do
      expect(rendered).to match_html(<<~HTML)
        <th class="type-attachment"></th>
      HTML
    end
  end

  context "when given a block" do
    it "renders the default value" do
      # this behaviour is intentional – assumes block is for body rendering, not header
      expect(rendered { "BLOCK" }).to match_html(<<~HTML)
        <th class="type-attachment">Image</th>
      HTML
    end
  end
end
