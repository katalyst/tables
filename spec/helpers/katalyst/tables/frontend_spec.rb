# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Frontend do
  include described_class

  let(:collection) { build(:collection, count: 1) }

  it "renders tables" do
    table_with(collection:) { |row| row.text :name }
    expect(rendered).to match_html(<<~HTML)
      <table>
        <thead><tr><th>Name</th></tr></thead>
        <tbody><tr><td>Person 1</td></tr></tbody>
      </table>
    HTML
  end

  it "passes html_options to table tag" do
    table_with(collection:, **Test::HTML_ATTRIBUTES) { |row| row.text :name }

    expect(rendered).to match_html(<<~HTML)
      <table id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">
        <thead><tr><th>Name</th></tr></thead>
        <tbody><tr><td>Person 1</td></tr></tbody>
      </table>
    HTML
  end

  it "supports custom table components" do
    table_with(collection:, component: CustomTableComponent) do |row|
      row.text :name
    end

    expect(rendered).to match_html(<<~HTML)
      <table class="custom-table">
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

  it "supports custom table components via controller defaults" do
    allow(controller).to receive(:default_table_component).and_return(CustomTableComponent)

    table_with(collection:) { |row| row.text :name }

    expect(rendered).to match_html(<<~HTML)
      <table class="custom-table">
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
