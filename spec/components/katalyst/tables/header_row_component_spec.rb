# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::HeaderRowComponent, type: :component do
  subject(:row) { described_class.new(table) }

  include_context "with table"

  it "renders an empty row" do
    expect(render_inline(row) { "" }).to match_html(<<~HTML)
      <tr></tr>
    HTML
  end

  it "renders cells" do
    expect(render_inline(row) do |row|
      row.cell(:key)
      row.cell(:key)
    end).to match_html(<<~HTML)
      <tr><th>Key</th><th>Key</th></tr>
    HTML
  end

  it "supports `options` from block" do
    expect(render_inline(row) do |row|
      row.options(id: "BLOCK", data: { block: "" })
    end).to match_html(<<~HTML)
      <tr id="BLOCK" data-block=""></tr>
    HTML
  end

  it "sets body? to false" do
    expect(render_inline(row) do |row|
      row.cell(:key, label: row.body?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>false</th></tr>
    HTML
  end

  it "sets header? to true" do
    expect(render_inline(row) do |row|
      row.cell(:key, label: row.header?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>true</th></tr>
    HTML
  end

  it "passes self and nil to block" do
    expect(render_inline(row) do |row, object|
      row.cell(:key, label: object.nil?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>true</th></tr>
    HTML
  end
end
