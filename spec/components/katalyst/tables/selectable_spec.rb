# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Selectable do
  let(:collection) do
    create_list(:person, 1)
    build(:collection, items: Person.all)
  end

  it "renders tables with the expected attributes to support selection" do
    component = Katalyst::TableComponent.new(collection:)
    html = render_inline(component) { |row, _| row.select }
    expect(html).to match_html(<<~HTML)
      <table>
        <thead><tr><th class="selection"></th></tr></thead>
        <tbody>
          <tr>
            <td class="selection"
                data-controller="tables--selection--item"
                data-tables--selection--item-params-value='{"id":1}'
                data-tables--selection--item-tables--selection--form-outlet="#people_selection_form"
                data-action="change->tables--selection--item#change"
                data-turbo-permanent="">
              <input type="checkbox">
            </td>
          </tr>
        </tbody>
      </table>
    HTML
  end

  it "renders form with the expected attributes to support selection" do
    component = Katalyst::Tables::Selectable::FormComponent.new(collection:)
    html = render_inline(component) do
      component.tag.button("Download", formaction: component.people_path(format: :csv), formmethod: :get)
    end
    expect(html).to match_html(<<~HTML)
      <form id="people_selection_form"
            class="tables--selection--form"
            data-controller="tables--selection--form"
            data-turbo-action="replace"
            data-turbo-permanent=""
            hidden="hidden"
            accept-charset="UTF-8"
            method="post">
        <input type="hidden" name="_method" value="patch" autocomplete="off">
        <p class="tables--selection--summary">
          <span data-tables--selection--form-target="count">0</span>
          <span data-tables--selection--form-target="singular" hidden>person</span>
          <span data-tables--selection--form-target="plural">people</span>
          selected
        </p>
        <button formaction="/people.csv" formmethod="get">Download</button>
      </form>
    HTML
  end
end
