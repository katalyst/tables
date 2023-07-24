# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Frontend do
  let(:template) { Test::Template.new }
  let(:items) { build(:relation) }

  delegate :table_with, to: :template

  it "creates a bare table" do
    expect(table_with(collection: items) { "" }).to match_html(<<~HTML)
      <table>
        <thead><tr></tr></thead>
        <tbody></tbody>
      </table>
    HTML
  end

  context "when html options are provided to table_with" do
    subject(:table) do
      table_with(collection: items, **Test::HTML_OPTIONS) { "" }
    end

    it "passes html_options to table tag" do
      expect(table).to match_html(<<~HTML)
        <table id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">
          <thead><tr></tr></thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when header: false" do
    subject(:table) { table_with(collection: items, header: false) { "" } }

    it "removes the header" do
      expect(table).to match_html(<<~HTML)
        <table>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when a column is provided" do
    subject(:table) { table_with(collection: items) { |row| row.cell :col_name } }

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
    subject(:table) { table_with(collection: items, object_name: "my_model") { |row| row.cell :col } }

    before do
      allow_any_instance_of(Katalyst::Tables::HeaderCellComponent)
        .to receive(:translate).with("activerecord.attributes.my_model.col", any_args).and_return("COL")
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
    subject(:table) do
      template.with_request_url("/resource?s=q&page=2") do
        table_with(collection: items, sort: sort) { |row| row.cell :name }
      end
    end

    let(:sort) { Katalyst::Tables::Backend::SortForm.new }

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

  context "when html options are passed to header row" do
    subject(:table) do
      table_with(collection: items) do |row|
        row.options(**Test::HTML_OPTIONS) if row.header?
        row.cell :name
      end
    end

    it "adds html options to header row tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">
              <th>Name</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when html options are passed to header cell" do
    subject(:table) do
      table_with(collection: items) do |row|
        row.cell :name, **(row.header? ? Test::HTML_OPTIONS : {})
      end
    end

    it "adds html options to header cell tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">Name</th>
            </tr>
          </thead>
          <tbody>
          </tbody>
        </table>
      HTML
    end
  end

  context "with collection data" do
    subject(:table) do
      table_with(collection: items) do |row|
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

  context "when html options are passed to body row" do
    subject(:table) do
      table_with(collection: items) do |row|
        row.options(**Test::HTML_OPTIONS) if row.body?
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
            <tr id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">
              <td>Resource 1</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "when html options are passed to body cell" do
    subject(:table) do
      table_with(collection: items) do |row|
        row.cell :name, **(row.body? ? Test::HTML_OPTIONS : {})
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
              <td id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">Resource 1</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "when body cell takes a block" do
    subject(:table) do
      table_with(collection: items) do |row|
        row.cell :name do |cell|
          template.link_to(cell.value, "/resource")
        end
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
              <td><a href="/resource">Resource 1</a></td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "with a custom table builder" do
    subject(:table) do
      table_with(collection: items, component: CustomTableComponent) do |row|
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

  context "with a custom table builder from the controller" do
    subject(:table) do
      table_with(collection: items) { nil }
    end

    it "adds custom classes to all tags" do
      allow(template.controller).to receive(:default_table_component).and_return(CustomTableComponent)
      expect(table).to match_html(<<~HTML)
        <table class="custom-table">
          <thead>
            <tr class="custom-header-row">
            </tr>
          </thead>
          <tbody>
          </tbody>
        </table>
      HTML
    end
  end

  context "with a custom builder that adds methods" do
    subject(:table) do
      table_with(collection: items, component: ActionTableComponent) do |row|
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
