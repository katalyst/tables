# frozen_string_literal: true

require "action_view/buffers"
require "action_view/helpers/tag_helper"
require "action_view/helpers/url_helper"

RSpec.describe Katalyst::Tables::Frontend, type: :view do
  include described_class
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper

  include_context "with collection"

  attr_accessor :output_buffer

  let(:controller) { double "controller" } # rubocop:disable RSpec/VerifiedDoubles

  let(:html_options) do
    {
      id: "ID",
      class: "CLASS",
      html: { style: "style" },
      data: { foo: "bar" }
    }
  end

  it "creates a bare table" do
    expect(table_with(collection: collection) { "" }).to match_html(<<~HTML)
      <table>
        <thead><tr></tr></thead>
        <tbody></tbody>
      </table>
    HTML
  end

  context "when html options are provided to table_with" do
    subject(:table) do
      table_with(collection: collection, **html_options) { "" }
    end

    it "passes html_options to table tag" do
      expect(table).to match_html(<<~HTML)
        <table id="ID" class="CLASS" style="style" data-foo="bar">
          <thead><tr></tr></thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when header: false" do
    subject(:table) { table_with(collection: collection, header: false) { "" } }

    it "removes the header" do
      expect(table).to match_html(<<~HTML)
        <table>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when a column is provided" do
    subject(:table) { table_with(collection: collection) { |row| row.cell :col_name } }

    it "renders a column header" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th>Col Name</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when model name is available" do
    subject(:table) { table_with(collection: collection, object_name: "my_model") { |row| row.cell :col } }

    before do
      allow(self).to receive(:translate).with("activerecord.attributes.my_model.col", any_args).and_return("COL")
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
    subject(:table) { table_with(collection: collection, sort: sort) { |row| row.cell :col } }

    let(:sort) { Katalyst::Tables::Backend::SortForm.new }

    include_context "with collection attribute"
    include_context "with mocked request", params: { "s" => "q", "page" => 2 }

    it "adds sort links" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th><a href="/resource?s=q&sort=col asc">Col</a></th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when html options are passed to header row" do
    subject(:table) do
      table_with(collection: collection) do |row|
        row.options(**html_options) if row.header?
        row.cell :col
      end
    end

    it "adds html options to header row tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr id="ID" class="CLASS" style="style" data-foo="bar">
              <th>Col</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      HTML
    end
  end

  context "when html options are passed to header cell" do
    subject(:table) do
      table_with(collection: collection) do |row|
        row.cell :col, **(row.header? ? html_options : {})
      end
    end

    it "adds html options to header cell tag" do
      expect(table).to match_html(<<~HTML)
        <table>
          <thead>
            <tr>
              <th id="ID" class="CLASS" style="style" data-foo="bar">Col</th>
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
      table_with(collection: collection) do |row|
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
    subject(:table) do
      table_with(collection: collection) do |row|
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
            <tr id="ID" class="CLASS" style="style" data-foo="bar">
              <td>value</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "when html options are passed to body cell" do
    subject(:table) do
      table_with(collection: collection) do |row|
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
              <td id="ID" class="CLASS" style="style" data-foo="bar">value</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "with a custom table builder" do
    subject(:table) do
      table_with(collection: collection, builder: Test::CustomTable) do |row|
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

  context "with a custom table builder from the controller" do
    subject(:table) do
      table_with(collection: collection) { nil }
    end

    it "adds custom classes to all tags" do
      allow(controller).to receive(:default_table_builder).and_return(Test::CustomTable)
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
      table_with(collection: collection, builder: Test::ActionTable) do |row|
        row.cell(:col) +
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
