# frozen_string_literal: true

class CustomTableComponent < Katalyst::TableComponent
  config.header_row = "CustomHeaderRow"
  config.header_cell = "CustomHeaderCell"
  config.body_row = "CustomBodyRow"
  config.body_cell = "CustomBodyCell"

  def call
    options(class: "custom-table")
    super
  end

  class CustomHeaderRow < Katalyst::Tables::HeaderRowComponent
    def call
      options(class: "custom-header-row")
      super
    end
  end

  class CustomHeaderCell < Katalyst::Tables::HeaderCellComponent
    def call
      options(class: "custom-header-cell")
      super
    end
  end

  class CustomBodyRow < Katalyst::Tables::BodyRowComponent
    def call
      options(class: "custom-body-row")
      super
    end
  end

  class CustomBodyCell < Katalyst::Tables::BodyCellComponent
    def call
      options(class: "custom-body-cell")
      super
    end
  end
end
