# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::TableComponent do
  subject(:component) { described_class.new(collection:) }

  let(:table) { render_inline(component) { |row| row.text(:name) } }
  let(:collection) { build(:collection, count: 1) }

  it "renders tables" do
    expect(table).to match_html(<<~HTML)
      <table class="katalyst--table">
        <thead><tr><th>Name</th></tr></thead>
        <tbody>
          <tr><td>Person 1</td></tr>
        </tbody>
      </table>
    HTML
  end

  it "supports minimal tables without header or caption" do
    table = render_inline(described_class.new(collection: [], caption: false, header: false))
    expect(table).to match_html(<<~HTML)
      <table class="katalyst--table">
        <tbody></tbody>
      </table>
    HTML
  end

  it "accepts html_attributes" do
    table = render_inline(described_class.new(collection: [], caption: false, header: false, **Test::HTML_ATTRIBUTES))
    expect(table).to match_html(<<~HTML)
      <table id="ID" class="katalyst--table CLASS" style="style" aria-label="LABEL" data-foo="bar">
        <tbody></tbody>
      </table>
    HTML
  end

  it "renders a header row" do
    table = render_inline(described_class.new(collection: [], caption: false, header: true)) { nil }
    expect(table).to match_html(<<~HTML)
      <table class="katalyst--table">
        <thead><tr></tr></thead>
        <tbody></tbody>
      </table>
    HTML
  end

  it "renders caption for empty collections" do
    table = render_inline(described_class.new(collection: build(:collection, count: 0))) { |row| row.text(:name) }
    expect(table).to match_html(<<~HTML)
      <table class="katalyst--table">
        <caption align="bottom">
          No people found.
        </caption>
        <thead>
          <tr><th>Name</th></tr>
        </thead>
        <tbody></tbody>
      </table>
    HTML
  end

  context "when model is available" do
    before do
      allow(Person).to receive(:human_attribute_name).with(:name).and_return("TRANSLATED")
    end

    it "translates column headers" do
      expect(table).to match_html(<<~HTML)
        <table class="katalyst--table">
          <thead>
            <tr>
              <th>TRANSLATED</th>
            </tr>
          </thead>
          <tbody>
            <tr><td>Person 1</td></tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "when html attributes are passed to header row" do
    let(:table) do
      render_inline(component) do |row|
        row.html_attributes = Test::HTML_ATTRIBUTES if row.header?
        row.text(:name)
      end
    end

    it "adds html options to header row tag" do
      expect(table).to match_html(<<~HTML)
        <table class="katalyst--table">
          <thead>
            <tr id="ID" aria-label="LABEL" class="CLASS" style="style" data-foo="bar">
              <th>Name</th>
            </tr>
          </thead>
          <tbody>
            <tr><td>Person 1</td></tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "when html attributes are passed to header cell" do
    let(:table) do
      render_inline(component) do |row|
        row.text :name, **(row.header? ? Test::HTML_ATTRIBUTES : {})
      end
    end

    it "adds html options to header cell tag" do
      expect(table).to match_html(<<~HTML)
        <table class="katalyst--table">
          <thead>
            <tr>
              <th id="ID" aria-label="LABEL" class="CLASS" style="style" data-foo="bar">Name</th>
            </tr>
          </thead>
          <tbody>
            <tr><td>Person 1</td></tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "when html attributes are passed to body row" do
    let(:table) do
      render_inline(component) do |row|
        row.html_attributes = Test::HTML_ATTRIBUTES if row.body?
        row.text :name
      end
    end

    it "adds html options to body row tag" do
      expect(table).to match_html(<<~HTML)
        <table class="katalyst--table">
          <thead>
            <tr>
              <th>Name</th>
            </tr>
          </thead>
          <tbody>
            <tr id="ID" aria-label="LABEL" class="CLASS" style="style" data-foo="bar">
              <td>Person 1</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "when html attributes are passed to body cell" do
    let(:table) do
      render_inline(component) do |row|
        row.text :name, **(row.body? ? Test::HTML_ATTRIBUTES : {})
      end
    end

    it "adds html options to body cell tag" do
      expect(table).to match_html(<<~HTML)
        <table class="katalyst--table">
          <thead>
            <tr>
              <th>Name</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td id="ID" aria-label="LABEL" class="CLASS" style="style" data-foo="bar">Person 1</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "when partial is inferred" do
    let(:table) { render_inline(component) }
    let(:collection) { build(:collection, type: :report, count: 1) }

    it "calls the partial to render rows" do
      expect(table.at_css("th:not([data-cell-type=selection])")).to match_html(<<~HTML)
        <th>Resource partial</th>
      HTML
    end

    context "when collection is empty" do
      let(:collection) { build(:collection, type: :resource, count: 0) }

      it "finds the partial from the collection" do
        expect(table.at_css("th:not([data-cell-type=selection])")).to match_html(<<~HTML)
          <th>Resource partial</th>
        HTML
      end
    end

    context "when collection is an array" do
      subject(:component) { described_class.new(collection: items, object_name: :resource) }

      let(:items) { build_list(:resource, 1) }

      it "finds the partial from the first row" do
        expect(table.at_css("th:not([data-cell-type=selection])")).to match_html(<<~HTML)
          <th>Resource partial</th>
        HTML
      end
    end

    context "when collection is an empty array" do
      let(:collection) { [] }

      it "renders empty headers as no partial is available" do
        expect(table).to match_html(<<~HTML)
          <table class="katalyst--table">
            <caption align="bottom">
              No records found.
            </caption>
            <thead><tr></tr></thead>
            <tbody></tbody>
          </table>
        HTML
      end
    end
  end

  context "with custom partial options" do
    let(:table) do
      render_inline(described_class.new(collection:, partial: "custom", as: :foobar))
    end

    let(:collection) { build(:collection, type: :resource, count: 1) }

    it "calls the custom partial with correct local" do
      expect(table).to match_html(<<~HTML)
        <table class="katalyst--table">
          <thead>
            <tr>
              <th>Custom partial</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Resource 1</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "with a custom table builder" do
    subject(:component) { CustomTableComponent.new(collection:) }

    let(:table) do
      render_inline(component) do |row|
        row.text :name
      end
    end

    it "adds custom classes to all tags" do
      expect(table).to match_html(<<~HTML)
        <table class="katalyst--table custom-table">
          <thead>
            <tr class="custom-header-row">
              <th class="custom-header-cell">Name</th>
            </tr>
          </thead>
          <tbody>
            <tr class="custom-body-row">
              <td class="custom-body-cell">Person 1</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "with a custom builder that adds methods" do
    subject(:component) { ActionTableComponent.new(collection:) }

    let(:table) do
      render_inline(component) do |row|
        row.text(:name)
        row.actions do |cell|
          cell.action("Edit", :edit) +
            cell.action("Delete", :delete, method: :delete)
        end
      end
    end

    it "generates actions column" do
      expect(table).to match_html(<<~HTML)
        <table class="action-table">
          <thead>
            <tr>
              <th>Name</th>
              <th class="actions"></th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Person 1</td>
              <td class="actions">
                <a href="edit">Edit</a>
                <a href="delete" method="delete">Delete</a>
              </td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "with a typed column" do
    let(:table) { render_inline(component) { |row| row.boolean(:active) } }

    it "renders boolean typed columns" do
      expect(table).to match_html(<<~HTML)
        <table class="katalyst--table">
          <thead><tr><th data-cell-type="boolean">Active</th></tr></thead>
          <tbody>
            <tr><td data-cell-type="boolean">Yes</td></tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "with a typed column passing a block" do
    let(:table) do
      render_inline(component) do |row|
        row.boolean(:active) do |cell|
          row.tag.span(cell)
        end
      end
    end

    it "renders boolean typed columns" do
      expect(table).to match_html(<<~HTML)
        <table class="katalyst--table">
          <thead><tr><th data-cell-type="boolean">Active</th></tr></thead>
          <tbody>
            <tr><td data-cell-type="boolean"><span>Yes</span></td></tr>
          </tbody>
        </table>
      HTML
    end
  end
end
