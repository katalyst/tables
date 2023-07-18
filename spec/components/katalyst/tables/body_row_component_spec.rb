# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::BodyRowComponent, type: :component do
  subject(:row) { described_class.new(table, record) }

  let(:record) { Test::Record.new(key: "VALUE") }

  include_context "with table"

  # simulate table passing its block to each row
  def render_row(&block)
    render_inline(row) do |row|
      block&.call(row, record)
    end
  end

  it "renders an empty row" do
    expect(render_row).to match_html(<<~HTML)
      <tr></tr>
    HTML
  end

  it "renders cells" do
    expect(render_row do |row|
      row.cell(:key)
      row.cell(:key)
    end).to match_html(<<~HTML)
      <tr><td>VALUE</td><td>VALUE</td></tr>
    HTML
  end

  it "supports `options` from block" do
    expect(render_row do |row|
      row.options(id: "BLOCK", data: { block: "" })
    end).to match_html(<<~HTML)
      <tr id="BLOCK" data-block=""></tr>
    HTML
  end

  it "sets body? to true" do
    expect(render_row do |row|
      row.cell(:key) { row.body?.inspect }
    end).to match_html(<<~HTML)
      <tr><td>true</td></tr>
    HTML
  end

  it "sets header? to false" do
    expect(render_row do |row|
      row.cell(:key) { row.header?.inspect }
    end).to match_html(<<~HTML)
      <tr><td>false</td></tr>
    HTML
  end

  it "passes self and record to block" do
    expect(render_row do |row, record|
      row.cell(:key) { record.key }
    end).to match_html(<<~HTML)
      <tr><td>VALUE</td></tr>
    HTML
  end
end
