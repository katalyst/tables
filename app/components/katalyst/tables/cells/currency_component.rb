# frozen_string_literal: true

require "bigdecimal/util"

module Katalyst
  module Tables
    module Cells
      # Formats the value as a money value
      #
      # The value is assumed to be cents if integer, or dollars if float or
      # decimal. Also supports RubyMoney type if defined.
      #
      # Adds a class to the cell to allow for custom styling
      class CurrencyComponent < CellComponent
        def initialize(options:, **)
          super(**)

          @options = options
        end

        def rendered_value
          format(value)
        end

        def format(value)
          value.present? ? number_to_currency(value, @options) : ""
        end

        def value
          case (v = super)
          when nil
            nil
          when Integer
            (super.to_d / BigDecimal("100"))
          else
            (v.to_d rescue nil) # rubocop:disable Style/RescueModifier
          end
        end

        private

        def default_html_attributes
          { class: "type-currency" }
        end
      end
    end
  end
end
