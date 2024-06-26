# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Date < Value
          include Helpers::Range

          define_range_patterns /\d{4}-\d\d-\d\d/

          def type
            :date
          end

          def serialize(value)
            if value.is_a?(::Date)
              value.to_fs(:db)
            else
              super
            end
          end

          private

          ISO_DATE = /\A(?<year>\d{4})-(?<month>\d\d)-(?<day>\d\d)\z/

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
