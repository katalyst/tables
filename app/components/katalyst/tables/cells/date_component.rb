# frozen_string_literal: true

module Katalyst
  module Tables
    module Cells
      # Formats the value as a date
      # @param format [String] date format
      # @param relative [Boolean] if true, the date may be(if within 5 days) shown as a relative date
      class DateComponent < CellComponent
        def initialize(format:, relative:, **)
          super(**)

          @format   = format
          @relative = relative
        end

        def value
          super&.to_date
        end

        def rendered_value
          @relative ? relative_time : absolute_time
        end

        private

        def default_html_attributes
          {
            class: "type-date",
            title: (absolute_time if row.body? && @relative && value.present? && days_ago_in_words(value).present?),
          }
        end

        def absolute_time
          value.present? ? I18n.l(value, format: @format) : ""
        end

        def relative_time
          if value.blank?
            ""
          else
            days_ago_in_words(value)&.capitalize || absolute_time
          end
        end

        def days_ago_in_words(value)
          from_time        = value.to_time
          to_time          = Date.current.to_time
          distance_in_days = ((to_time - from_time) / (24.0 * 60.0 * 60.0)).round

          case distance_in_days
          when 0
            "today"
          when 1
            "yesterday"
          when -1
            "tomorrow"
          when 2..5
            "#{distance_in_days} days ago"
          when -5..-2
            "#{distance_in_days.abs} days from now"
          end
        end
      end
    end
  end
end
