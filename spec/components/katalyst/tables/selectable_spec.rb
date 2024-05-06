# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Selectable do
  let(:collection) do
    create_list(:person, 1)
    build(:collection, items: Person.all)
  end

  def with_extensions(component)
    component
      .extend(Katalyst::Tables::Selectable)
  end

  it "renders tables with the expected attributes to support selection" do
    component = with_extensions(Katalyst::TableComponent.new(collection:))
    html = render_inline(component) { |row, _| row.select }
    expect(html).to match_html(<<~HTML)
      <table>
        <thead><tr><th class="selection"></th></tr></thead>
        <tbody>
          <tr>
            <td class="selection" data-controller="tables--selection--item" data-tables--selection--item-params-value='{"id":1}' data-tables--selection--item-tables--selection--form-outlet="#_selection" data-action="change->tables--selection--item#change" data-turbo-permanent=""><input type="checkbox"></td>
          </tr>
        </tbody>
      </table>
    HTML
  end
end
