# frozen_string_literal: true

module Katalyst
  module Tables
    module Selectable
      class SelectComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes

        def initialize(table, row, params, **)
          super(**)

          @table  = table
          @row    = row
          @params = params
        end

        def call
          tag.input(type: :checkbox)
        end

        def inspect
          "#<#{self.class.name} table: #{@table.inspect}, row: #{@row.inspect}, params: #{@params.inspect}>"
        end

        private

        def default_html_attributes
          if @row.header?
            { class: "selection" }
          else
            {
              class: "selection",
              data:  {
                controller:                                    ITEM_CONTROLLER,
                "#{ITEM_CONTROLLER}-params-value"              => @params.to_json,
                "#{ITEM_CONTROLLER}-#{FORM_CONTROLLER}-outlet" => "##{@table.id}_selection",
                action:                                        "change->#{ITEM_CONTROLLER}#change",
                turbo_permanent:                               "",
              },
            }
          end
        end
      end
    end
  end
end
