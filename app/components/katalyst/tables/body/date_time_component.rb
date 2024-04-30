# frozen_string_literal: true

module Katalyst
  module Tables
    module Body
      # Formats the value as a datetime
      # @param format [String] datetime format, defaults to :admin
      # @param relative [Boolean] if true, the datetime may be(if today) shown as a relative date/time
      class DateTimeComponent < BodyCellComponent
        include ActionView::Helpers::DateHelper

        def initialize(table, record, attribute, format: :table, relative: true, **options)
          super(table, record, attribute, **options)

          @format   = format
          @relative = relative
        end

        def value
          super&.to_datetime
        end

        def rendered_value
          @relative ? relative_time : absolute_time
        end

        private

        def absolute_time
          value.present? ? I18n.l(value, format: @format) : ""
        end

        def today?
          value&.to_date == Date.current
        end

        def relative_time
          return "" if value.blank?

          if today?
            if value > DateTime.current
              "#{distance_of_time_in_words(value, DateTime.current)} from now".capitalize
            else
              "#{distance_of_time_in_words(value, DateTime.current)} ago".capitalize
            end
          else
            absolute_time
          end
        end

        def default_html_attributes
          @relative && today? ? { title: absolute_time } : {}
        end
      end
    end
  end
end
