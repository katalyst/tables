# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Body::CurrencyComponent do
  subject(:cell) { described_class.new(table, record, :count) }

  let(:table) { Katalyst::TableComponent.new(collection: Resource.all, id: "table") }
  let(:record) { build(:resource, count: 1) }

  before do
    record
  end

  it "renders column" do
    expect(render_inline(cell)).to match_html(<<~HTML)
      <td class="type-currency">$0.01</td>
    HTML
  end

  context "with nil values" do
    let(:record) { build(:resource, count: nil) }

    it "renders as a string" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td class="type-currency"></td>
      HTML
    end
  end

  context "when given a block" do
    it "renders the block's value" do
      expect(render_inline(cell) { "BLOCK" }).to match_html(<<~HTML)
        <td class="type-currency">BLOCK</td>
      HTML
    end

    it "allows block to access value" do
      expect(render_inline(cell) { |cell| cell.value.to_s }).to match_html(<<~HTML)
        <td class="type-currency">1</td>
      HTML
    end
  end

  context "with html_options" do
    subject(:cell) { described_class.new(table, record, :count, **Test::HTML_ATTRIBUTES) }

    it "renders tag with html_options" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td id="ID" class="type-currency CLASS" style="style" data-foo="bar" aria-label="LABEL">$0.01</td>
      HTML
    end
  end
end
