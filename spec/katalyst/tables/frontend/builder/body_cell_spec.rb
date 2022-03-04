# frozen_string_literal: true

RSpec.describe Katalyst::Tables::Frontend::Builder::BodyCell do
  subject(:cell) { described_class.new(table, object, :key) }

  include_context "with table"

  let(:object) { Test::Record.new(key: "VALUE") }

  it "renders the object's attribute value" do
    expect(cell.build).to match_html(<<~HTML)
      <td>VALUE</td>
    HTML
  end

  context "when heading" do
    subject(:cell) { described_class.new(table, object, :key, heading: true) }

    it "renders a table header tag" do
      expect(cell.build).to match_html(<<~HTML)
        <th>VALUE</th>
      HTML
    end
  end

  context "with html_options" do
    subject(:cell) { described_class.new(table, object, :key, **html_options) }

    it "renders tag with html_options" do
      expect(cell.build).to match_html(<<~HTML)
        <td id="ID" class="CLASS" style="style" data-foo="bar">VALUE</td>
      HTML
    end
  end

  context "when given a block" do
    it "renders the block's value" do
      expect(cell.build { "BLOCK" }).to match_html(<<~HTML)
        <td>BLOCK</td>
      HTML
    end

    it "allows block to access value" do
      expect(cell.build { |cell| cell.value.titleize }).to match_html(<<~HTML)
        <td>Value</td>
      HTML
    end
  end

  context "with html_options from args and block" do
    subject(:cell) { described_class.new(table, object, :key, **html_options) }

    it "uses block options instead of args" do
      expect(cell.build do |cell|
        cell.options(id: "BLOCK", data: { block: "" })
        "BLOCK"
      end).to match_html(<<~HTML)
        <td id="BLOCK" data-block="">BLOCK</td>
      HTML
    end
  end
end
