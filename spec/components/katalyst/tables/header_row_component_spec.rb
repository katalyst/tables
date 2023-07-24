# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::HeaderRowComponent do
  subject(:row) { described_class.new(table) }

  let(:table) do
    instance_double(Katalyst::TableComponent).tap do |table|
      allow(table).to receive_messages(sort: sort, object_name: "resource", collection: items)
    end
  end
  let(:items) { build(:relation) }
  let(:sort) { nil }

  before do
    allow(table.class).to receive(:header_cell_component).and_return(Katalyst::Tables::HeaderCellComponent)
  end

  it "renders an empty row" do
    expect(render_inline(row) { "" }).to match_html(<<~HTML)
      <tr></tr>
    HTML
  end

  it "renders cells" do
    expect(render_inline(row) do |row|
      row.cell(:name)
      row.cell(:name)
    end).to match_html(<<~HTML)
      <tr><th>Name</th><th>Name</th></tr>
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
      row.cell(:name, label: row.body?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>false</th></tr>
    HTML
  end

  it "sets header? to true" do
    expect(render_inline(row) do |row|
      row.cell(:name, label: row.header?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>true</th></tr>
    HTML
  end

  it "passes self and nil to block" do
    expect(render_inline(row) do |row, object|
      row.cell(:name, label: object.nil?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>true</th></tr>
    HTML
  end
end
