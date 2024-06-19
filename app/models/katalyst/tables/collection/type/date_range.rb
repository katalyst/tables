# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class DateRange < ActiveModel::Type::Value
          def type
            :date_range
          end

          def serialize(value)
            if value.is_a?(Date)
              value.to_fs(:db)
            elsif value.is_a?(Range)
              if value.begin.nil?
                "<#{value.end.to_fs(:db)}"
              elsif value.end.nil?
                ">#{value.begin.to_fs(:db)}"
              else
                "#{value.begin.to_fs(:db)}..#{value.end.to_fs(:db)}"
              end
            else
              value.to_s
            end
          end

          private

          ISO_DATE = /\A(\d{4})-(\d\d)-(\d\d)\z/
          LOWER_BOUND = /\A>(\d{4})-(\d\d)-(\d\d)\z/
          UPPER_BOUND = /\A<(\d{4})-(\d\d)-(\d\d)\z/
          BOUNDED = /\A(\d{4})-(\d\d)-(\d\d)\.\.(\d{4})-(\d\d)-(\d\d)\z/

          def cast_value(value)
            return value unless value.is_a?(String)

            if value =~ ISO_DATE
              new_date($1.to_i, $2.to_i, $3.to_i)
            elsif value =~ LOWER_BOUND
              (new_date($1.to_i, $2.to_i, $3.to_i)..)
            elsif value =~ UPPER_BOUND
              (..new_date($1.to_i, $2.to_i, $3.to_i))
            elsif value =~ BOUNDED
              (new_date($1.to_i, $2.to_i, $3.to_i)..new_date($4.to_i, $5.to_i, $6.to_i))
            else
              value
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
