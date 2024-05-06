# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::HeaderRowComponent do
  let(:table) { Katalyst::TableComponent.new(collection:) }
  let(:collection) { build_list(:person, 1) }

  def render_row(&)
    render_inline(table, &).at_css("thead tr")
  end

  it "renders an empty row" do
    expect(render_row { "" }).to match_html(<<~HTML)
      <tr></tr>
    HTML
  end

  it "renders cells" do
    expect(render_row do |row|
      row.cell(:name)
      row.cell(:name)
    end).to match_html(<<~HTML)
      <tr><th>Name</th><th>Name</th></tr>
    HTML
  end

  it "renders typed cells" do
    expect(render_row do |row|
      row.cell(:name)
      row.boolean(:active)
      row.date(:created_at)
      row.datetime(:created_at)
      row.number(:count)
      row.currency(:count)
      row.link(:id)
      row.attachment(:image)
    end).to match_html(<<~HTML)
      <tr>
        <th>Name</th>
        <th class="type-boolean">Active</th>
        <th class="type-date">Created at</th>
        <th class="type-datetime">Created at</th>
        <th class="type-number">Count</th>
        <th class="type-currency">Count</th>
        <th class="type-link">Id</th>
        <th class="type-attachment">Image</th>
      </tr>
    HTML
  end

  context "with a rich text model" do
    let(:record) { create(:faq) }

    it "renders typed cells" do
      expect(render_row do |row|
        row.rich_text(:answer)
      end).to match_html(<<~HTML)
        <tr>
            <th class="type-rich-text">Answer</th>
        </tr>
      HTML
    end
  end

  it "supports `options` from block" do
    expect(render_row do |row|
      row.html_attributes = { id: "BLOCK", data: { block: "" } }
    end).to match_html(<<~HTML)
      <tr id="BLOCK" data-block=""></tr>
    HTML
  end

  it "sets body? to false" do
    expect(render_row do |row|
      row.cell(:name, label: row.body?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>false</th></tr>
    HTML
  end

  it "sets header? to true" do
    expect(render_row do |row|
      row.cell(:name, label: row.header?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>true</th></tr>
    HTML
  end

  it "passes self and nil to block" do
    expect(render_row do |row, object|
      row.cell(:name, label: object.nil?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>true</th></tr>
    HTML
  end

  it "allows column widths" do
    expect(render_row do |row|
      row.cell(:name, width: :s)
    end).to match_html(<<~HTML)
      <tr><th class="width-s">Name</th></tr>
    HTML
  end
end
