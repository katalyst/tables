# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Frontend do
  include described_class

  let(:collection) { build(:collection, count: 1) }

  it "renders tables" do
    expect(table_with(collection:) { |row| row.cell :name }).to match_html(<<~HTML)
      <table>
        <thead><tr><th>Name</th></tr></thead>
        <tbody><tr id="person_1"><td>Person 1</td></tr></tbody>
      </table>
    HTML
  end

  context "when html options are provided to table_with" do
    subject(:table) do
      table_with(collection:, **Test::HTML_ATTRIBUTES) { |row| row.cell :name }
    end

    it "passes html_options to table tag" do
      expect(table).to match_html(<<~HTML)
        <table id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">
          <thead><tr><th>Name</th></tr></thead>
          <tbody><tr id="person_1"><td>Person 1</td></tr></tbody>
        </table>
      HTML
    end
  end

  context "with a custom table builder" do
    subject(:table) do
      table_with(collection:, component: CustomTableComponent) do |row|
        row.cell :name
      end
    end

    it "adds custom classes to all tags" do
      expect(table).to match_html(<<~HTML)
        <table class="custom-table">
          <thead>
            <tr class="custom-header-row">
              <th class="custom-header-cell">Name</th>
            </tr>
          </thead>
          <tbody>
            <tr id="person_1" class="custom-body-row">
              <td class="custom-body-cell">Person 1</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "with a custom table builder from the controller" do
    subject(:table) do
      table_with(collection:) { |row| row.cell :name }
    end

    it "adds custom classes to all tags" do
      allow(controller).to receive(:default_table_component).and_return(CustomTableComponent)
      expect(table).to match_html(<<~HTML)
        <table class="custom-table">
          <thead>
            <tr class="custom-header-row">
              <th class="custom-header-cell">Name</th>
            </tr>
          </thead>
          <tbody>
            <tr id="person_1" class="custom-body-row">
              <td class="custom-body-cell">Person 1</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end
end
