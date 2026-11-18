# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Date < Value
          include Helpers::Range

          ISO_DATE = /\A(?<year>\d{4})-(?<month>\d\d)-(?<day>\d\d)\z/

          define_range_patterns /\d{4}-\d\d-\d\d/

          def type
            :date
          end

          def to_param(value)
            case value
            when ::Date, ::DateTime, ::Time, ActiveSupport::TimeWithZone
              value.to_date.to_fs(:db)
            else
              super
            end
          end

          def suggestions(scope, attribute)
            [
              *super(scope, attribute, limit: 6, order: :desc),
              database_suggestion(attribute:, value: ::Date.current.beginning_of_week..),
              database_suggestion(attribute:, value: ::Date.current.beginning_of_month..),
              database_suggestion(attribute:, value: 1.month.ago.all_month),
              database_suggestion(attribute:, value: 1.year.ago.all_year),
            ]
          end

          private

          # Dates filtering a datetime column are interpreted as whole days in Time.zone.
          def apply_filter(scope, model, attribute, value)
            return super unless value && datetime_column?(model, attribute.name.split(".").last)

            scope.where(attribute.name => to_time_range(value))
          end

          def datetime_column?(model, column)
            %i[datetime timestamptz].include?(model.type_for_attribute(column).type)
          end

          # Converts a date or range of dates to an exclusive range of times that
          # covers each day in full, from the start of the first day to the start
          # of the day after the last.
          def to_time_range(value)
            from, to = value.is_a?(::Range) ? [value.begin, value.end] : [value, value]

            from&.in_time_zone...to&.next_day&.in_time_zone
          end

          def cast_value(value)
            return value unless value.is_a?(::String)

            if /\A(?<year>\d{4})-(?<month>\d\d)-(?<day>\d\d)\z/ =~ value
              new_date(year.to_i, month.to_i, day.to_i)
            end
          end

          def new_date(year, mon, mday)
            return nil if year.nil? || (year.zero? && mon.zero? && mday.zero?)

            ::Date.new(year, mon, mday)
          rescue ArgumentError, TypeError
            nil
          end
        end
      end
    end
  end
end
