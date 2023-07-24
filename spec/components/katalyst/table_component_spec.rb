# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::TableComponent do
  subject(:component) { described_class.new(collection: items) }

  let(:table) { render_inline(component) { "" } }
  let(:items) { build(:relation) }

  it "creates a bare table" do
    expect(table).to match_html(<<~HTML)
      <table>
        <thead><tr></tr></thead>
        <tbody></tbody>
      </table>
    HTML
  end

  context "when html attributes are provided" do
    subject(:component) { described_class.new(collection: items, **Test::HTML_ATTRIBUTES) }

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
    subject(:component) { described_class.new(collection: items, header: false) }

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
        row.cell :name
      end
    end

    it "renders a column header" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th>Name</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when model name is available" do
    subject(:component) { described_class.new(collection: items, object_name: "resource") }

    let(:table) do
      render_inline(component) do |row|
        row.cell :name
      end
    end

    before do
      allow_any_instance_of(Katalyst::Tables::HeaderCellComponent)
        .to receive(:translate).with("activerecord.attributes.resource.name", any_args)
                               .and_return("TRANSLATED")
    end

    it "translates column headers" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th>TRANSLATED</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when sort is provided" do
    subject(:component) { described_class.new(collection: items, sort: sort) }

    let(:sort) { Katalyst::Tables::Backend::SortForm.new }

    let(:table) do
      with_request_url("/resource?s=q&page=2") do
        render_inline(component) do |row|
          row.cell :name
        end
      end
    end

    it "adds sort links" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th><a href="/resource?s=q&sort=name+asc">Name</a></th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when html attributes are passed to header row" do
    let(:table) do
      render_inline(component) do |row|
        row.options(**Test::HTML_ATTRIBUTES) if row.header?
        row.cell :name
      end
    end

    it "adds html options to header row tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr id="ID" aria-label="LABEL" class="CLASS" style="style" data-foo="bar">
              <th>Name</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when html attributes are passed to header cell" do
    let(:table) do
      render_inline(component) do |row|
        row.cell :name, **(row.header? ? Test::HTML_ATTRIBUTES : {})
      end
    end

    it "adds html options to header cell tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th id="ID" aria-label="LABEL" class="CLASS" style="style" data-foo="bar">Name</th>
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
        row.cell :name
      end
    end

    let(:items) { build(:relation, count: 1) }

    it "adds html options to header row tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th>Name</th>
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

  context "when html attributes are passed to body row" do
    let(:table) do
      render_inline(component) do |row|
        row.options(**Test::HTML_ATTRIBUTES) if row.body?
        row.cell :name
      end
    end

    let(:items) { build(:relation, count: 1) }

    it "adds html options to body row tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th>Name</th>
            </tr>
          </thead>
          <tbody>
            <tr id="ID" aria-label="LABEL" class="CLASS" style="style" data-foo="bar">
              <td>Resource 1</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "when html attributes are passed to body cell" do
    let(:table) do
      render_inline(component) do |row|
        row.cell :name, **(row.body? ? Test::HTML_ATTRIBUTES : {})
      end
    end

    let(:items) { build(:relation, count: 1) }

    it "adds html options to body cell tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th>Name</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td id="ID" aria-label="LABEL" class="CLASS" style="style" data-foo="bar">Resource 1</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "with a custom table builder" do
    subject(:component) { CustomTableComponent.new(collection: items) }

    let(:table) do
      render_inline(component) do |row|
        row.cell :name
      end
    end

    let(:items) { build(:relation, count: 1) }

    it "adds custom classes to all tags" do
      expect(table).to match_html(<<~HTML)
        <table class="custom-table">
          <thead>
            <tr class="custom-header-row">
              <th class="custom-header-cell">Name</th>
            </tr>
          </thead>
          <tbody>
            <tr class="custom-body-row">
              <td class="custom-body-cell">Resource 1</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "with a custom builder that adds methods" do
    subject(:component) { ActionTableComponent.new(collection: items) }

    let(:table) do
      render_inline(component) do |row|
        row.cell(:name)
        row.actions do |cell|
          cell.action("Edit", :edit) +
            cell.action("Delete", :delete, method: :delete)
        end
      end
    end

    let(:items) { build(:relation, count: 1) }

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
              <td>Resource 1</td>
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
