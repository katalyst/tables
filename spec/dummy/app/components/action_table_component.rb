# frozen_string_literal: true

class ActionTableComponent < Katalyst::TableComponent
  config.header_row = "ActionHeaderRow"
  config.body_row   = "ActionBodyRow"
  config.body_cell  = "ActionBodyCell"

  def call
    self.html_attributes = { class: "action-table" }
    super
  end

  class ActionHeaderRow < Katalyst::Tables::HeaderRowComponent
    def actions(&)
      cell(:actions, class: "actions", label: "", &)
    end
  end

  class ActionBodyRow < Katalyst::Tables::BodyRowComponent
    def actions(&)
      cell(:actions, class: "actions", &)
    end
  end

  class ActionBodyCell < Katalyst::Tables::BodyCellComponent
    def action(label, href, **opts)
      content_tag :a, label, { href: }.merge(opts)
    end
  end
end
