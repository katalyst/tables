# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Cells::DateComponent do
  let(:table) { Katalyst::TableComponent.new(collection:) }
  let(:collection) { create_list(:resource, 1, count: 1) }
  let(:rendered) { render_inline(table) { |row| row.date(:created_at) } }
  let(:label) { rendered.at_css("thead th") }
  let(:data) { rendered.at_css("tbody td") }

  it "renders column header" do
    expect(label).to match_html(<<~HTML)
      <th class="type-date">Created at</th>
    HTML
  end

  it "renders column data" do
    expect(data).to match_html(<<~HTML)
      <td class="type-date" title="#{I18n.l(collection.first.created_at.to_date, format: :default)}">Today</td>
    HTML
  end

  context "with html_options" do
    let(:rendered) { render_inline(table) { |row| row.date(:created_at, **Test::HTML_ATTRIBUTES) } }

    it "renders header with html_options" do
      expect(label).to match_html(<<~HTML)
        <th id="ID" class="type-date CLASS" style="style" data-foo="bar" aria-label="LABEL">Created at</th>
      HTML
    end

    it "renders data with html_options" do
      expect(data).to match_html(<<~HTML)
        <td id="ID" class="type-date CLASS" style="style" data-foo="bar" aria-label="LABEL" title="#{I18n.l(collection.first.created_at.to_date, format: :default)}">Today</td>
      HTML
    end
  end

  context "when given a label" do
    let(:rendered) { render_inline(table) { |row| row.date(:created_at, label: "LABEL") } }

    it "renders header with label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-date">LABEL</th>
      HTML
    end

    it "renders data without label" do
      expect(data).to match_html(<<~HTML)
        <td class="type-date" title="#{I18n.l(collection.first.created_at.to_date, format: :default)}">Today</td>
      HTML
    end
  end

  context "when given an empty label" do
    let(:rendered) { render_inline(table) { |row| row.date(:created_at, label: "") } }

    it "renders header with an empty label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-date"></th>
      HTML
    end
  end

  context "with nil data value" do
    let(:collection) { build_list(:resource, 1, created_at: nil) }

    it "renders data as empty" do
      expect(data).to match_html(<<~HTML)
        <td class="type-date"></td>
      HTML
    end
  end

  context "when given a block" do
    let(:rendered) { render_inline(table) { |row| row.date(:created_at) { |cell| cell.tag.span(cell) } } }

    it "renders the default header" do
      expect(label).to match_html(<<~HTML)
        <th class="type-date">Created at</th>
      HTML
    end

    it "renders the custom data" do
      expect(data).to match_html(<<~HTML)
        <td class="type-date" title="#{I18n.l(collection.first.created_at.to_date, format: :default)}"><span>Today</span></td>
      HTML
    end
  end

  context "when given a block that uses value" do
    let(:rendered) do
      render_inline(table) do |row|
        row.date(:created_at) do |cell|
          cell.tag.span(I18n.l(cell.value, format: :short))
        end
      end
    end

    it "allows block to access value" do
      expect(data).to match_html(<<~HTML)
        <td class="type-date" title="#{I18n.l(collection.first.created_at.to_date, format: :default)}"><span>#{I18n.l(collection.first.created_at.to_date, format: :short)}</span></td>
      HTML
    end
  end

  context "when not relative" do
    let(:rendered) { render_inline(table) { |row| row.date(:created_at, relative: false) } }

    it "renders column data" do
      expect(data).to match_html(<<~HTML)
        <td class="type-date">#{I18n.l(collection.first.created_at.to_date, format: :default)}</td>
      HTML
    end
  end

  context "when future date" do
    let(:collection) { create_list(:resource, 1, created_at: 3.days.from_now) }

    it "renders column data" do
      expect(data).to match_html(<<~HTML)
        <td class="type-date" title="#{I18n.l(collection.first.created_at.to_date, format: :default)}">3 days from now</td>
      HTML
    end
  end
end
