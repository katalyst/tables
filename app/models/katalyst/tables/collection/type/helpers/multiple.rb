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
                value.map { |v| super(v) }
              elsif multiple?
                [super]
              else
                super
              end
            end

            def deserialize(value)
              if multiple? && value.is_a?(::Array)
                value.map { |v| super(v) }.flatten
              elsif multiple?
                [super].flatten.compact
              else
                super
              end
            end

            def serialize(value)
              if multiple? && value.is_a?(::Array)
                value.map { |v| super(v) }.flatten
              else
                super
              end
            end

            using Extensions

            def default_value
              multiple? ? [] : super
            end
          end
        end
      end
    end
  end
end
