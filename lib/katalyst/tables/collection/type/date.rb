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
