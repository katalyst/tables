# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::BodyRowComponent do
  include Rails.application.routes.url_helpers

  subject(:row) { described_class.new(table, record) }

  let(:table) { instance_double(Katalyst::TableComponent) }
  let(:record) { create(:resource, :with_image, name: "VALUE", active: true, count: 1) }

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
      row.number(:count)
      row.currency(:count)
      row.link(:id)
    end).to match_html(<<~HTML)
      <tr>
        <td>Yes</td>
        <td title="#{I18n.l(record.created_at.to_date, format: :table)}">Today</td>
        <td title="#{I18n.l(record.created_at.to_datetime, format: :table)}">Less than a minute ago</td>
        <td class="type-number">1</td>
        <td class="type-currency">$0.01</td>
        <td><a href="/resources/#{record.id}">#{record.id}</a></td>
      </tr>
    HTML
  end

  it "renders attachment cells" do
    expect(render_row do |row|
      row.attachment(:image)
    end).to have_css("td > img[src*='dummy.png']")
  end

  context "with a rich text model" do
    let(:record) { create(:faq) }

    it "renders typed cells" do
      expect(render_row do |row|
        row.rich_text(:answer)
      end).to match_html(<<~HTML)
        <tr>
          <td title="#{record.answer.to_plain_text}">#{record.answer}</td>
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

  context "with dom id generation" do
    subject(:row) { described_class.new(table, record).extend(Katalyst::Tables::Identifiable::BodyRow) }

    it "generates a dom id" do
      expect(render_row).to match_html(<<~HTML)
        <tr id="resource_1"></tr>
      HTML
    end
  end
end
