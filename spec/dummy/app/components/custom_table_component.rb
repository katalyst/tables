# frozen_string_literal: true

class CustomTableComponent < Katalyst::TableComponent
  config.header_row = "CustomHeaderRow"
  config.header_cell = "CustomHeaderCell"
  config.body_row = "CustomBodyRow"
  config.body_cell = "CustomBodyCell"

  def call
    self.html_attributes = { class: "custom-table" }
    super
  end

  class CustomHeaderRow < Katalyst::Tables::HeaderRowComponent
    def call
      self.html_attributes = { class: "custom-header-row" }
      super
    end
  end

  class CustomHeaderCell < Katalyst::Tables::HeaderCellComponent
    def call
      self.html_attributes = { class: "custom-header-cell" }
      super
    end
  end

  class CustomBodyRow < Katalyst::Tables::BodyRowComponent
    def call
      self.html_attributes = { class: "custom-body-row" }
      super
    end
  end

  class CustomBodyCell < Katalyst::Tables::BodyCellComponent
    def call
      self.html_attributes = { class: "custom-body-cell" }
      super
    end
  end
end
