# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        module Helpers
          # Lifts a delegating type from value to arrays of values
          module Delegate
            delegate :type, to: :@delegate

            def initialize(delegate:, **arguments)
              super(**arguments)

              @delegate = delegate.new(**arguments.except(:filter, :multiple, :scope))
            end

            using Extensions

            def deserialize(value)
              if multiple? && value.is_a?(::Array)
                value.map { |v| @delegate.deserialize(v) }
              else
                @delegate.deserialize(value)
              end
            end

            def serialize(value)
              if multiple? && value.is_a?(::Array)
                value.map { |v| @delegate.serialize(v) }
              else
                @delegate.serialize(value)
              end
            end

            private

            def cast_value(value)
              if multiple? && value.is_a?(::Array)
                value.map { |v| @delegate.cast(v) }
              else
                @delegate.cast(value)
              end
            end
          end
        end
      end
    end
  end
end
