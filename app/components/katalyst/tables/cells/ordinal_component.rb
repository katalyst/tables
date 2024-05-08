# frozen_string_literal: true

module Katalyst
  module Tables
    module Cells
      class OrdinalComponent < CellComponent
        def initialize(primary_key:, **)
          super(**)

          @primary_key = primary_key
        end

        def rendered_value
          t("katalyst.tables.orderable.value")
        end

        private

        def default_html_attributes
          if @row.header?
            { class: "ordinal" }
          else
            {
              class: "ordinal",
              data:  {
                controller:                                   Orderable::ITEM_CONTROLLER,
                "#{Orderable::ITEM_CONTROLLER}-params-value": params.to_json,
              },
            }
          end
        end

        def params
          {
            id_name:     @primary_key,
            id_value:    record.public_send(@primary_key),
            index_name:  column,
            index_value: record.public_send(column),
          }
        end
      end
    end
  end
end
