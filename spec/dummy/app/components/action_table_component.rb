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
    def actions(&block)
      cell(:actions, class: "actions", label: "", &block)
    end
  end

  class ActionBodyRow < Katalyst::Tables::BodyRowComponent
    def actions(&block)
      cell(:actions, class: "actions", &block)
    end
  end

  class ActionBodyCell < Katalyst::Tables::BodyCellComponent
    def action(label, href, **opts)
      content_tag :a, label, { href: href }.merge(opts)
    end
  end
end
