# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::TableComponent, type: :component do
  subject(:component) { described_class.new(collection: collection) }

  include_context "with collection"

  let(:table) do
    render_inline(component) { "" }
  end

  let(:html_options) do
    {
      id: "ID",
      class: "CLASS",
      html: { style: "style" },
      aria: { label: "LABEL" },
      data: { foo: "bar" }
    }
  end

  it "creates a bare table" do
    expect(table).to match_html(<<~HTML)
      <table>
        <thead><tr></tr></thead>
        <tbody></tbody>
      </table>
    HTML
  end

  context "when html options are provided" do
    subject(:component) { described_class.new(collection: collection, **html_options) }

    it "passes html_options to table tag" do
      expect(table).to match_html(<<~HTML)
        <table id="ID" class="CLASS" style="style" aria-label="LABEL" data-foo="bar">
          <thead><tr></tr></thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when header: false" do
    subject(:component) { described_class.new(collection: collection, header: false) }

    it "removes the header" do
      expect(table).to match_html(<<~HTML)
        <table>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when a column is provided" do
    let(:table) do
      render_inline(component) do |row|
        row.cell :col_name
      end
    end

    it "renders a column header" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th>Col name</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when model name is available" do
    subject(:component) { described_class.new(collection: collection, object_name: "my_model") }

    let(:table) do
      render_inline(component) do |row|
        row.cell :col
      end
    end

    before do
      allow_any_instance_of(Katalyst::Tables::HeaderCellComponent)
        .to receive(:translate).with("activerecord.attributes.my_model.col", any_args)
                               .and_return("COL")
    end

    it "translates column headers" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th>COL</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when sort is provided" do
    subject(:component) { described_class.new(collection: collection, sort: sort) }

    let(:sort) { Katalyst::Tables::Backend::SortForm.new }

    let(:table) do
      with_request_url("/resource?s=q&page=2") do
        render_inline(component) do |row|
          row.cell :col
        end
      end
    end

    include_context "with collection attribute"

    it "adds sort links" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th><a href="/resource?s=q&sort=col+asc">Col</a></th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when html options are passed to header row" do
    let(:table) do
      render_inline(component) do |row|
        row.options(**html_options) if row.header?
        row.cell :col
      end
    end

    it "adds html options to header row tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr id="ID" aria-label="LABEL" class="CLASS" style="style" data-foo="bar">
              <th>Col</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when html options are passed to header cell" do
    let(:table) do
      render_inline(component) do |row|
        row.cell :col, **(row.header? ? html_options : {})
      end
    end

    it "adds html options to header cell tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th id="ID" aria-label="LABEL" class="CLASS" style="style" data-foo="bar">Col</th>
            </tr>
          </thead>
          <tbody>
          </tbody>
        </table>
      HTML
    end
  end

  context "with collection data" do
    let(:table) do
      render_inline(component) do |row|
        row.cell :col
      end
    end

    include_context "with collection data", ["value"]

    it "adds html options to header row tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th>Col</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>value</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "when html options are passed to body row" do
    let(:table) do
      render_inline(component) do |row|
        row.options(**html_options) if row.body?
        row.cell :col
      end
    end

    include_context "with collection data", ["value"]

    it "adds html options to body row tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th>Col</th>
            </tr>
          </thead>
          <tbody>
            <tr id="ID" aria-label="LABEL" class="CLASS" style="style" data-foo="bar">
              <td>value</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "when html options are passed to body cell" do
    let(:table) do
      render_inline(component) do |row|
        row.cell :col, **(row.body? ? html_options : {})
      end
    end

    include_context "with collection data", ["value"]

    it "adds html options to body cell tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th>Col</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td id="ID" aria-label="LABEL" class="CLASS" style="style" data-foo="bar">value</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "with a custom table builder" do
    subject(:component) { CustomTableComponent.new(collection: collection) }

    let(:table) do
      render_inline(component) do |row|
        row.cell :col
      end
    end

    include_context "with collection data", ["value"]

    it "adds custom classes to all tags" do
      expect(table).to match_html(<<~HTML)
        <table class="custom-table">
          <thead>
            <tr class="custom-header-row">
              <th class="custom-header-cell">Col</th>
            </tr>
          </thead>
          <tbody>
            <tr class="custom-body-row">
              <td class="custom-body-cell">value</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "with a custom builder that adds methods" do
    subject(:component) { ActionTableComponent.new(collection: collection) }

    let(:table) do
      render_inline(component) do |row|
        row.cell(:col)
        row.actions do |cell|
          cell.action("Edit", :edit) +
            cell.action("Delete", :delete, method: :delete)
        end
      end
    end

    include_context "with collection data", ["value"]

    it "generates actions column" do
      expect(table).to match_html(<<~HTML)
        <table class="action-table">
          <thead>
            <tr>
              <th>Col</th>
              <th class="actions"></th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>value</td>
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
end
