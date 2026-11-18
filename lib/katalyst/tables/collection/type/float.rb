# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Float < Value
          include Helpers::Delegate
          include Helpers::Multiple
          include Helpers::Range

          define_range_patterns(/-?\d+(?:\.\d+)?/)

          def initialize(**)
            super(**, delegate: ActiveModel::Type::Float)
          end

          private

          # ActiveModel accepts "NaN", but NaN is not equal to anything, so
          # treat it as invalid input.
          def cast_value(value)
            result = super
            result unless result.is_a?(::Float) && result.nan?
          end
        end
      end
    end
  end
end
