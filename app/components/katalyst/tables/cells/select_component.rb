# frozen_string_literal: true

module Katalyst
  module Tables
    module Cells
      class SelectComponent < CellComponent
        def initialize(params:, form_id:, **)
          super(**)

          @params  = params
          @form_id = form_id
        end

        def rendered_value
          tag.input(type: :checkbox)
        end

        private

        def default_html_attributes
          if @row.header?
            { class: "selection" }
          else
            {
              class: "selection",
              data:  {
                controller:                                    Selectable::ITEM_CONTROLLER,
                "#{Selectable::ITEM_CONTROLLER}-params-value"              => @params.to_json,
                "#{Selectable::ITEM_CONTROLLER}-#{Selectable::FORM_CONTROLLER}-outlet" => "##{@form_id}",
                action:                                        "change->#{Selectable::ITEM_CONTROLLER}#change",
                turbo_permanent:                               "",
              },
            }
          end
        end
      end
    end
  end
end
