# frozen_string_literal: true

module Katalyst
  module Tables
    module Cells
      class SelectComponent < CellComponent
        def initialize(params:, form_id:, **)
          super(**)

          @params = params
          @form_id = form_id
        end

        def label
          tag.label(tag.input(type: :checkbox))
        end

        def rendered_value
          tag.label(tag.input(type: :checkbox))
        end

        private

        def default_html_attributes
          if @row.header?
            {
              class: "selection",
              data:  {
                "#{Selectable::TABLE_CONTROLLER}-target" => "header",
                action: "change->#{Selectable::TABLE_CONTROLLER}#toggleHeader",
              },
            }
          else
            {
              class: "selection",
              data:  {
                controller: Selectable::ITEM_CONTROLLER,
                action: "change->#{Selectable::ITEM_CONTROLLER}#change",
                "#{Selectable::ITEM_CONTROLLER}-params-value" => @params.to_json,
                "#{Selectable::ITEM_CONTROLLER}-#{Selectable::FORM_CONTROLLER}-outlet" => "##{@form_id}",
                "#{Selectable::TABLE_CONTROLLER}-target" => "item",
              },
            }
          end
        end
      end
    end
  end
end
