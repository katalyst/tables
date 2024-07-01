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

            def serialize(value)
              if value.is_a?(::Range)
                if value.begin.nil?
                  "..#{serialize(value.end)}"
                elsif value.end.nil?
                  "#{serialize(value.begin)}.."
                else
                  "#{serialize(value.begin)}..#{serialize(value.end)}"
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
                ((super($~[:lower]))..)
              when self.class.const_get(:UPPER_BOUND)
                (..(super($~[:upper])))
              when self.class.const_get(:BOUNDED)
                ((super($~[:lower]))..(super($~[:upper])))
              else
                super
              end
            end
          end
        end
      end
    end
  end
end
