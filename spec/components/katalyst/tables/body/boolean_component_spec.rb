# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Body::BooleanComponent do
  subject(:cell) { described_class.new(table, record, :active) }

  let(:table) { Katalyst::TableComponent.new(collection: Person.all, id: "table") }
  let(:record) { build(:person, active: true) }

  before do
    record
  end

  it "renders column" do
    expect(render_inline(cell)).to match_html(<<~HTML)
      <td>Yes</td>
    HTML
  end

  context "with nil values" do
    let(:record) { build(:resource, active: nil) }

    it "renders as a string" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td>No</td>
      HTML
    end
  end

  context "when given a block" do
    it "renders the block's value" do
      expect(render_inline(cell) { "BLOCK" }).to match_html(<<~HTML)
        <td>BLOCK</td>
      HTML
    end

    it "allows block to access value" do
      expect(render_inline(cell) { |cell| cell.value.to_s }).to match_html(<<~HTML)
        <td>true</td>
      HTML
    end
  end

  context "with html_options" do
    subject(:cell) { described_class.new(table, record, :active, **Test::HTML_ATTRIBUTES) }

    it "renders tag with html_options" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">Yes</td>
      HTML
    end
  end
end
