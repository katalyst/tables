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
      <table class="katalyst--table"
             data-controller="tables--selection--table"
             data-tables--selection--table-tables--selection--form-outlet="#people_selection_form"
             data-action="tables--selection--item:select->tables--selection--table#update">
        <thead>
          <tr>
            <th data-cell-type="selection"
                data-tables--selection--table-target="header"
                data-action="change->tables--selection--table#toggleHeader">
              <label><input type="checkbox"></label>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td data-cell-type="selection"
                data-controller="tables--selection--item"
                data-action="change->tables--selection--item#change"
                data-tables--selection--item-params-value='{"id":1}'
                data-tables--selection--item-tables--selection--form-outlet="#people_selection_form"
                data-tables--selection--table-target="item">
              <label><input type="checkbox"></label>
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
            hidden="hidden"
            accept-charset="UTF-8"
            method="post">
        <input type="hidden" name="_method" value="patch">
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
