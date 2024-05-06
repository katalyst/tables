# frozen_string_literal: true

class CustomTableComponent < Katalyst::TableComponent
  def initialize(*, **, &)
    super

    update_html_attributes(class: "custom-table")

    add_header_row_callback do |row|
      row.update_html_attributes(class: "custom-header-row")
    end

    add_body_row_callback do |row|
      row.update_html_attributes(class: "custom-body-row")
    end

    add_header_row_cell_callback do |cell|
      cell.update_html_attributes(class: "custom-header-cell")
    end

    add_body_row_cell_callback do |row|
      row.update_html_attributes(class: "custom-body-cell")
    end
  end
end
