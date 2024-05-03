# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Identifiable do
  let(:collection) do
    create_list(:person, 1)
    build(:collection, items: Person.all)
  end

  def with_extensions(component)
    component
      .extend(Katalyst::Tables::Identifiable)
  end

  it "renders tables with the expected id and data attributes" do
    component = with_extensions(Katalyst::TableComponent.new(collection:))
    html = render_inline(component) { |row| row.cell(:name) }
    expect(html).to match_html(<<~HTML)
      <table id="people">
        <thead><tr><th>Name</th></tr></thead>
        <tbody>
          <tr id="person_1"><td>Person 1</td></tr>
        </tbody>
      </table>
    HTML
  end

  it "supports minimal tables without header or caption" do
    component = with_extensions(Katalyst::TableComponent.new(collection:, caption: false, header: false))
    html = render_inline(component) { |row| row.cell(:name) }
    expect(html).to match_html(<<~HTML)
      <table id="people">
        <tbody>
          <tr id="person_1"><td>Person 1</td></tr>
        </tbody>
      </table>
    HTML
  end

  it "accepts html_attributes with higher precedence than the provided ids" do
    component = with_extensions(Katalyst::TableComponent.new(collection:, **Test::HTML_ATTRIBUTES))
    html = render_inline(component) do |row, person|
      row.html_attributes = { id: "test_#{person.id}" } if person
      row.cell(:name)
    end
    expect(html).to match_html(<<~HTML)
      <table id="ID" class="CLASS" style="style" aria-label="LABEL" data-foo="bar">
        <thead><tr><th>Name</th></tr></thead>
        <tbody>
          <tr id="test_1"><td>Person 1</td></tr>
        </tbody>
      </table>
    HTML
  end
end
