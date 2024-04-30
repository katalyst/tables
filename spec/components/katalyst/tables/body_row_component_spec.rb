# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::BodyRowComponent do
  subject(:row) { described_class.new(table, record) }

  let(:table) { instance_double(Katalyst::TableComponent) }
  let(:record) { create(:resource, name: "VALUE", active: true) }

  before do
    allow(table).to receive(:body_cell_component).and_return(Katalyst::Tables::BodyCellComponent)
  end

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
      row.cell(:name)
      row.cell(:name)
    end).to match_html(<<~HTML)
      <tr><td>VALUE</td><td>VALUE</td></tr>
    HTML
  end

  it "renders typed cells" do
    expect(render_row do |row|
      row.boolean(:active)
      row.date(:created_at)
      row.datetime(:created_at)
    end).to match_html(<<~HTML)
      <tr><td>Yes</td><td title="#{I18n.l(record.created_at.to_date, format: :table)}">Today</td><td title="#{I18n.l(record.created_at.to_datetime, format: :table)}">Less than a minute ago</td></tr>
    HTML
  end

  it "supports `options` from block" do
    expect(render_row do |row|
      row.html_attributes = { id: "BLOCK", data: { block: "" } }
    end).to match_html(<<~HTML)
      <tr id="BLOCK" data-block=""></tr>
    HTML
  end

  it "sets body? to true" do
    expect(render_row do |row|
      row.cell(:name) { row.body?.inspect }
    end).to match_html(<<~HTML)
      <tr><td>true</td></tr>
    HTML
  end

  it "sets header? to false" do
    expect(render_row do |row|
      row.cell(:name) { row.header?.inspect }
    end).to match_html(<<~HTML)
      <tr><td>false</td></tr>
    HTML
  end

  it "passes self and record to block" do
    expect(render_row do |row, record|
      row.cell(:name) { record.name }
    end).to match_html(<<~HTML)
      <tr><td>VALUE</td></tr>
    HTML
  end
end
