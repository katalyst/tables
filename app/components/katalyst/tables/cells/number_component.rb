# frozen_string_literal: true

module Katalyst
  module Tables
    module Cells
      # Formats the value as a number
      #
      # Adds a class to the cell to allow for custom styling
      class NumberComponent < CellComponent
        include ActiveSupport::NumberHelper

        def initialize(format:, options:, **)
          super(**)

          @format = format
          @options = options
        end

        def format(value)
          case @format
          when :phone
            number_to_phone(value, @options)
          when :currency
            number_to_currency(value, @options)
          when :percentage
            number_to_percentage(value, @options)
          when :delimited
            number_to_delimited(value, @options)
          when :rounded
            number_to_rounded(value, @options)
          when :human_size
            number_to_human_size(value, @options)
          when :human
            number_to_human(value, @options)
          else
            raise ArgumentError, "Unsupported format #{@format}"
          end
        end

        def rendered_value
          value.present? ? format(value) : ""
        end

        private

        def default_html_attributes
          { class: "type-number" }
        end
      end
    end
  end
end
