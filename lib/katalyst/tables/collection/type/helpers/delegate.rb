# frozen_string_literal: true

require "katalyst/tables/collection/type/helpers/extensions"

module Katalyst
  module Tables
    module Collection
      module Type
        module Helpers
          # Lifts a delegating type from value to arrays of values
          module Delegate
            delegate :type, :deserialize, :serialize, to: :@delegate

            def initialize(delegate:, **arguments)
              super(**arguments)

              @delegate = delegate.new(**arguments.except(:filter, :multiple, :scope))
            end

            using Extensions

            private

            def cast_value(value)
              @delegate.cast(value)
            end
          end
        end
      end
    end
  end
end
