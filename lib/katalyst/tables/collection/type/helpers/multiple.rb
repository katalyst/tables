# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        module Helpers
          # Adds support for multiple: true
          module Multiple
            def initialize(multiple: false, **)
              super(**)

              @multiple = multiple
            end

            def multiple?
              @multiple
            end

            def cast(value)
              return (multiple? ? [] : nil) if value.nil?

              if multiple? && value.is_a?(::Array)
                value_for_multiple(value.flat_map { |v| cast(v) })
              elsif multiple?
                value_for_multiple(super)
              else
                super
              end
            end

            def deserialize(value)
              if multiple? && value.is_a?(::Array)
                value.map { |v| deserialize(v) }.flatten
              elsif multiple?
                [super].flatten.compact
              else
                super
              end
            end

            def serialize(value)
              if multiple? && value.is_a?(::Array)
                value.map { |v| serialize(v) }.flatten
              else
                super
              end
            end

            def to_param(value)
              if multiple? && value.is_a?(::Array)
                "[#{value.map { |v| to_param(v) }.flatten.join(', ')}]"
              else
                super
              end
            end

            using Extensions

            def default_value
              multiple? ? [] : super
            end

            def value_for_multiple(value)
              case value
              when ::Array
                value.reject { |v| v.is_a?(::Range) }
              when ::Range
                value
              else
                [value]
              end
            end
          end
        end
      end
    end
  end
end
