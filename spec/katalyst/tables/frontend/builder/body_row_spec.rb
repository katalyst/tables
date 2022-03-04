# frozen_string_literal: true

RSpec.describe Katalyst::Tables::Frontend::Builder::BodyRow do
  let(:object) { Test::Record.new(key: "VALUE") }

  include_context "with table"

  it "renders an empty row" do
    expect(described_class.new(table, object).build { "" }).to match_html(<<~HTML)
      <tr></tr>
    HTML
  end

  it "renders cells" do
    expect(described_class.new(table, object).build do |row|
      row.cell(:key) + row.cell(:key)
    end).to match_html(<<~HTML)
      <tr><td>VALUE</td><td>VALUE</td></tr>
    HTML
  end

  it "supports `options` from block" do
    expect(described_class.new(table, object).build do |row|
      row.options(id: "BLOCK", data: { block: "" })
    end).to match_html(<<~HTML)
      <tr id="BLOCK" data-block=""></tr>
    HTML
  end

  it "sets body? to true" do
    expect(described_class.new(table, object).build do |row|
      row.cell(:key) { row.body? }
    end).to match_html(<<~HTML)
      <tr><td>true</td></tr>
    HTML
  end

  it "sets header? to false" do
    expect(described_class.new(table, object).build do |row|
      row.cell(:key) { row.header? }
    end).to match_html(<<~HTML)
      <tr><td>false</td></tr>
    HTML
  end

  it "passes self and object to block" do
    expect(described_class.new(table, object).build do |row, object|
      row.cell(:key) { object.key }
    end).to match_html(<<~HTML)
      <tr><td>VALUE</td></tr>
    HTML
  end
end
