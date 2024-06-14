# frozen_string_literal: true

module Katalyst
  # A component for rendering a summary table for a model.
  # @example
  #    <%= Katalyst::SummaryTableComponent.new(model: @person) do |row, person| %>
  #      <%= row.text :name do |cell| %>
  #        <%= link_to cell.value, person %>
  #      <% end %>
  #      <%= row.text :email %>
  #    <% end %>
  # Generates:
  #     <table>
  #       <tr><th>Name</th><td><a href="/people/1">Aaron</a></td></tr>
  #       <tr><th>Email</th><td>aaron@example.com</td></tr>
  #     </table>
  class SummaryTableComponent < TableComponent
    renders_many :summary_rows, Tables::Summary::RowComponent

    def initialize(model:, **)
      super(collection: [model], **)

      @summary_rows = []

      update_html_attributes(class: "summary-table")
    end

    def with_cell(cell, &)
      if row.header?
        @summary_rows << with_summary_row do |row|
          row.with_header do |header|
            header.with_cell(cell)
          end
        end
        @index = 0
      else
        @summary_rows[@index].with_body do |body|
          body.with_cell(cell, &)
        end
        @index += 1
      end
    end
  end
end
