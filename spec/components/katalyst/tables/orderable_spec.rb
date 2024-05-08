# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Orderable do
  let(:collection) do
    create_list(:faq, 1)
    build(:collection, items: Faq.all)
  end
  let(:form_id) { "faqs_order_form" }

  it "renders tables with the expected attributes to support selection" do
    component = Katalyst::TableComponent.new(collection:)
    html = render_inline(component) { |row, _| row.ordinal }
    expect(html).to match_html(<<~HTML)
      <table>
        <thead><tr><th class="ordinal"></th></tr></thead>
        <tbody data-controller="tables--orderable--list"
                data-action="mousedown->tables--orderable--list#mousedown"
                data-tables--orderable--list-tables--orderable--form-outlet="##{form_id}"
                data-tables--orderable--list-tables--orderable--item-outlet="td.ordinal">
          <tr>
            <td class="ordinal"
                data-controller="tables--orderable--item"
                data-tables--orderable--item-params-value='{"id_name":"id","id_value":1,"index_name":"ordinal","index_value":1}'>
              ⠿
            </td>
          </tr>
        </tbody>
      </table>
    HTML
  end

  it "renders form with the expected attributes to support selection" do
    component = Katalyst::Tables::Orderable::FormComponent.new(collection:, url: vc_test_controller.order_faqs_path)
    html = render_inline(component)
    expect(html).to match_html(<<~HTML)
      <form id="#{form_id}"
            data-controller="tables--orderable--form"
            data-tables--orderable--form-scope-value="order[faqs]"
            action="/faqs/order" accept-charset="UTF-8" method="post">
        <input type="hidden" name="_method" value="patch" autocomplete="off">
        <button name="button" type="submit" hidden="hidden">Save </button>
      </form>
    HTML
  end
end
