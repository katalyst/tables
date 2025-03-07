# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Cells::BooleanComponent do
  let(:table) { Katalyst::TableComponent.new(collection:) }
  let(:collection) { build_list(:person, 1, active: true) }
  let(:rendered) { render_inline(table) { |row| row.boolean(:active) } }
  let(:label) { rendered.at_css("thead th") }
  let(:data) { rendered.at_css("tbody td") }

  it "renders column header" do
    expect(label).to match_html(<<~HTML)
      <th data-cell-type="boolean">Active</th>
    HTML
  end

  it "renders column data" do
    expect(data).to match_html(<<~HTML)
      <td data-cell-type="boolean">Yes</td>
    HTML
  end

  context "with html_options" do
    let(:rendered) { render_inline(table) { |row| row.boolean(:active, **Test::HTML_ATTRIBUTES) } }

    it "renders header with html_options" do
      expect(label).to match_html(<<~HTML)
        <th id="ID" data-cell-type="boolean" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">Active</th>
      HTML
    end

    it "renders data with html_options" do
      expect(data).to match_html(<<~HTML)
        <td id="ID" data-cell-type="boolean" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">Yes</td>
      HTML
    end
  end

  context "when given a label" do
    let(:rendered) { render_inline(table) { |row| row.boolean(:active, label: "LABEL") } }

    it "renders header with label" do
      expect(label).to match_html(<<~HTML)
        <th data-cell-type="boolean">LABEL</th>
      HTML
    end

    it "renders data without label" do
      expect(data).to match_html(<<~HTML)
        <td data-cell-type="boolean">Yes</td>
      HTML
    end
  end

  context "when given an empty label" do
    let(:rendered) { render_inline(table) { |row| row.boolean(:active, label: "") } }

    it "renders header with an empty label" do
      expect(label).to match_html(<<~HTML)
        <th data-cell-type="boolean"></th>
      HTML
    end
  end

  context "with nil data value" do
    let(:collection) { build_list(:person, 1, active: nil) }

    it "renders data as falsey" do
      expect(data).to match_html(<<~HTML)
        <td data-cell-type="boolean">No</td>
      HTML
    end
  end

  context "when given a block" do
    let(:rendered) { render_inline(table) { |row| row.boolean(:active) { |cell| cell.tag.span(cell) } } }

    it "renders the default header" do
      expect(label).to match_html(<<~HTML)
        <th data-cell-type="boolean">Active</th>
      HTML
    end

    it "renders the custom data" do
      expect(data).to match_html(<<~HTML)
        <td data-cell-type="boolean"><span>Yes</span></td>
      HTML
    end
  end

  context "when given a block that uses value" do
    let(:rendered) { render_inline(table) { |row| row.boolean(:active) { |cell| cell.tag.span(cell.value) } } }

    it "allows block to access value" do
      expect(data).to match_html(<<~HTML)
        <td data-cell-type="boolean"><span>true</span></td>
      HTML
    end
  end
end
