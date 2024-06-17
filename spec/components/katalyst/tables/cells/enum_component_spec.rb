# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Cells::EnumComponent do
  let(:table) { Katalyst::TableComponent.new(collection:) }
  let(:collection) { create_list(:resource, 1, category: :report) }
  let(:rendered) { render_inline(table) { |row, _| row.enum(:category) } }
  let(:label) { rendered.at_css("thead th") }
  let(:data) { rendered.at_css("tbody td") }

  it "renders column header" do
    expect(label).to match_html(<<~HTML)
      <th class="type-enum">Category</th>
    HTML
  end

  it "renders column data" do
    expect(data).to match_html(<<~HTML)
      <td class="type-enum"><small data-enum="category" data-value="report">Report</small></td>
    HTML
  end

  context "with html_options" do
    let(:rendered) { render_inline(table) { |row| row.enum(:category, **Test::HTML_ATTRIBUTES) } }

    it "renders header with html_options" do
      expect(label).to match_html(<<~HTML)
        <th id="ID" class="type-enum CLASS" style="style" data-foo="bar" aria-label="LABEL">Category</th>
      HTML
    end

    it "renders data with html_options" do
      expect(data).to match_html(<<~HTML)
        <td id="ID" class="type-enum CLASS" style="style" data-foo="bar" aria-label="LABEL"><small data-enum="category" data-value="report">Report</small></td>
      HTML
    end
  end

  context "when given a label" do
    let(:rendered) { render_inline(table) { |row| row.enum(:category, label: "LABEL") } }

    it "renders header with label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-enum">LABEL</th>
      HTML
    end

    it "renders data without label" do
      expect(data).to match_html(<<~HTML)
        <td class="type-enum"><small data-enum="category" data-value="report">Report</small></td>
      HTML
    end
  end

  context "when given an empty label" do
    let(:rendered) { render_inline(table) { |row| row.enum(:category, label: "") } }

    it "renders header with an empty label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-enum"></th>
      HTML
    end
  end

  context "with nil data value" do
    let(:rendered) { render_inline(table) { |row| row.enum(:category) } }

    it "renders an empty cell" do
      allow(collection.first).to receive(:category).and_return(nil)
      expect(data).to match_html(<<~HTML)
        <td class="type-enum"></td>
      HTML
    end
  end

  context "when given a block" do
    let(:rendered) { render_inline(table) { |row| row.enum(:category) { |cell| cell.tag.small(cell) } } }

    it "renders the default header" do
      expect(label).to match_html(<<~HTML)
        <th class="type-enum">Category</th>
      HTML
    end

    it "renders the custom data" do
      expect(data).to match_html(<<~HTML)
        <td class="type-enum"><small><small data-enum="category" data-value="report">Report</small></small></td>
      HTML
    end
  end
end
