# frozen_string_literal: true

class ActionTableComponent < Katalyst::TableComponent
  def actions(column = :_actions, label: "", heading: false, **, &)
    with_cell(ActionsComponent.new(collection:, row:, column:, record:, label:, heading:, **), &)
  end

  def default_html_attributes
    { class: "action-table" }
  end

  class ActionsComponent < Katalyst::Tables::CellComponent
    def action(label, href, **opts)
      content_tag :a, label, { href: }.merge(opts)
    end

    def default_html_attributes
      { class: "actions" }
    end
  end
end
