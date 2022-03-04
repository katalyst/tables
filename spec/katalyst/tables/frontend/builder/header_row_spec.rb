# frozen_string_literal: true

RSpec.describe Katalyst::Tables::Frontend::Builder::HeaderRow do
  include_context "with table"

  it "renders an empty row" do
    expect(described_class.new(table).build { "" }).to match_html(<<~HTML)
      <tr></tr>
    HTML
  end

  it "renders cells" do
    expect(described_class.new(table).build do |row|
      row.cell(:key) + row.cell(:key)
    end).to match_html(<<~HTML)
      <tr><th>Key</th><th>Key</th></tr>
    HTML
  end

  it "supports `options` from block" do
    expect(described_class.new(table).build do |row|
      row.options(id: "BLOCK", data: { block: "" })
    end).to match_html(<<~HTML)
      <tr id="BLOCK" data-block=""></tr>
    HTML
  end

  it "sets body? to false" do
    expect(described_class.new(table).build do |row|
      row.cell(:key, label: row.body?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>false</th></tr>
    HTML
  end

  it "sets header? to true" do
    expect(described_class.new(table).build do |row|
      row.cell(:key, label: row.header?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>true</th></tr>
    HTML
  end

  it "passes self and nil to block" do
    expect(described_class.new(table).build do |row, object|
      row.cell(:key, label: object.nil?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>true</th></tr>
    HTML
  end
end
