# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Cells::NumberComponent do
  let(:table) { Katalyst::TableComponent.new(collection:) }
  let(:collection) { build_list(:resource, 1, count: 1) }
  let(:rendered) { render_inline(table) { |row| row.number(:count) } }
  let(:label) { rendered.at_css("thead th") }
  let(:data) { rendered.at_css("tbody td") }

  it "renders column header" do
    expect(label).to match_html(<<~HTML)
      <th class="type-number">Count</th>
    HTML
  end

  it "renders column data" do
    expect(data).to match_html(<<~HTML)
      <td class="type-number">1</td>
    HTML
  end

  context "with html_options" do
    let(:rendered) { render_inline(table) { |row| row.number(:count, **Test::HTML_ATTRIBUTES) } }

    it "renders header with html_options" do
      expect(label).to match_html(<<~HTML)
        <th id="ID" class="type-number CLASS" style="style" data-foo="bar" aria-label="LABEL">Count</th>
      HTML
    end

    it "renders data with html_options" do
      expect(data).to match_html(<<~HTML)
        <td id="ID" class="type-number CLASS" style="style" data-foo="bar" aria-label="LABEL">1</td>
      HTML
    end
  end

  context "when given a label" do
    let(:rendered) { render_inline(table) { |row| row.number(:count, label: "LABEL") } }

    it "renders header with label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-number">LABEL</th>
      HTML
    end

    it "renders data without label" do
      expect(data).to match_html(<<~HTML)
        <td class="type-number">1</td>
      HTML
    end
  end

  context "when given an empty label" do
    let(:rendered) { render_inline(table) { |row| row.number(:count, label: "") } }

    it "renders header with an empty label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-number"></th>
      HTML
    end
  end

  context "with nil data value" do
    let(:collection) { build_list(:resource, 1, count: nil) }

    it "renders data as empty" do
      expect(data).to match_html(<<~HTML)
        <td class="type-number"></td>
      HTML
    end
  end

  context "with a large data value" do
    let(:collection) { build_list(:resource, 1, count: 1_000_000_000) }

    it "renders data with commas" do
      expect(data).to match_html(<<~HTML)
        <td class="type-number">1,000,000,000</td>
      HTML
    end
  end

  context "with a format argument" do
    let(:rendered) do
      render_inline(table) do |row|
        row.number(:count, label: "", format: :human, options: { units: { unit: "m", thousand: "km" } })
      end
    end
    let(:collection) { build_list(:resource, 1, count: 1024) }

    it "renders data with unit" do
      expect(data).to match_html(<<~HTML)
        <td class="type-number">1.02 km</td>
      HTML
    end
  end

  context "with a string data value" do
    let(:collection) { build_list(:resource, 1, count: "invalid") }

    it "renders data using number_to_human's convert" do
      expect(data).to match_html(<<~HTML)
        <td class="type-number">0</td>
      HTML
    end
  end

  context "when given a block" do
    let(:rendered) { render_inline(table) { |row| row.number(:count) { |cell| cell.tag.span(cell) } } }

    it "renders the default header" do
      expect(label).to match_html(<<~HTML)
        <th class="type-number">Count</th>
      HTML
    end

    it "renders the custom data" do
      expect(data).to match_html(<<~HTML)
        <td class="type-number"><span>1</span></td>
      HTML
    end
  end

  context "when given a block that uses value" do
    let(:rendered) do
      render_inline(table) do |row|
        row.number(:count) do |cell|
          cell.tag.span(cell.number_to_percentage(cell.value))
        end
      end
    end

    it "allows block to access value" do
      expect(data).to match_html(<<~HTML)
        <td class="type-number"><span>1.000%</span></td>
      HTML
    end
  end
end
