# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::BodyCellComponent do
  subject(:cell) { described_class.new(table, record, :name) }

  let(:table) { instance_double(Katalyst::TableComponent) }
  let(:record) { build(:resource, name: "VALUE") }

  it "renders the record's attribute value" do
    expect(render_inline(cell)).to match_html(<<~HTML)
      <td>VALUE</td>
    HTML
  end

  context "when heading" do
    subject(:cell) { described_class.new(table, record, :name, heading: true) }

    it "renders a table header tag" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <th>VALUE</th>
      HTML
    end
  end

  context "with html_options" do
    subject(:cell) { described_class.new(table, record, :name, **Test::HTML_ATTRIBUTES) }

    it "renders tag with html_options" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">VALUE</td>
      HTML
    end
  end

  context "with boolean values" do
    subject(:cell) { described_class.new(table, record, :active) }

    let(:record) { build(:resource, active: false) }

    it "renders as a string" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td>false</td>
      HTML
    end
  end

  context "with nil values" do
    let(:record) { build(:resource, name: nil) }

    it "renders as a string" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td></td>
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
      expect(render_inline(cell) { |cell| cell.value.titleize }).to match_html(<<~HTML)
        <td>Value</td>
      HTML
    end
  end

  context "with html_attributes from args and block" do
    subject(:cell) { described_class.new(table, record, :name, **Test::HTML_ATTRIBUTES) }

    it "uses block options instead of args" do
      expect(render_inline(cell) do |cell|
        cell.html_attributes = { id: "BLOCK", data: { block: "" } }
        "BLOCK"
      end).to match_html(<<~HTML)
        <td id="BLOCK" data-block="">BLOCK</td>
      HTML
    end
  end
end
