# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        module Helpers
          # Adds support for ranges
          module Range
            extend ActiveSupport::Concern

            class_methods do
              # @param single_value [Regex] pattern for accepting a single value
              def define_range_patterns(single_value)
                const_set(:SINGLE_VALUE, /\A(?<value>#{single_value})\z/)
                const_set(:LOWER_BOUND, /\A(?<lower>#{single_value})\.\.\z/)
                const_set(:UPPER_BOUND, /\A\.\.(?<upper>#{single_value})\z/)
                const_set(:BOUNDED, /\A(?<lower>#{single_value})\.\.(?<upper>#{single_value})\z/)
              end
            end

            def deserialize(value)
              if value.is_a?(::Range)
                if value.begin.nil?
                  make_range(nil, deserialize(value.end))
                elsif value.end.nil?
                  make_range(deserialize(value.begin), nil)
                else
                  make_range(deserialize(value.begin), deserialize(value.end))
                end
              else
                super
              end
            end

            def serialize(value)
              if value.is_a?(::Range)
                if value.begin.nil?
                  make_range(nil, serialize(value.end))
                elsif value.end.nil?
                  make_range(serialize(value.begin), nil)
                else
                  make_range(serialize(value.begin), serialize(value.end))
                end
              else
                super
              end
            end

            def to_param(value)
              if value.is_a?(::Range)
                if value.begin.nil?
                  "..#{to_param(value.end)}"
                elsif value.end.nil?
                  "#{to_param(value.begin)}.."
                else
                  "#{to_param(value.begin)}..#{to_param(value.end)}"
                end
              else
                super
              end
            end

            def cast(value)
              case value
              when nil
                nil
              when ::Range
                value
              when self.class.const_get(:SINGLE_VALUE)
                super($~[:value])
              when self.class.const_get(:LOWER_BOUND)
                make_range(super($~[:lower]), nil)
              when self.class.const_get(:UPPER_BOUND)
                make_range(nil, super($~[:upper]))
              when self.class.const_get(:BOUNDED)
                make_range(super($~[:lower]), super($~[:upper]))
              else
                super
              end
            end

            private

            def make_range(from, to)
              # when a value that accepts multiple is given a range, it double-packs the value so we get ..[0]
              # unpack the array value
              from = from.first if from.is_a?(::Array) && from.length == 1
              to = to.first if to.is_a?(::Array) && to.length == 1
              (from..to)
            end
          end
        end
      end
    end
  end
end
