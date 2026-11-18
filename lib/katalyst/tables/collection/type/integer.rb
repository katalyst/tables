# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Integer < Value
          include Helpers::Delegate
          include Helpers::Multiple
          include Helpers::Range

          define_range_patterns(/-?\d+/)

          def initialize(**)
            super(**, delegate: Unbounded)
          end

          # Integer values are checked against the column's range by Active
          # Record when filtering, which matches nothing for out of range values.
          # BigInteger skips ActiveModel's own 4 byte range check, and limit: 8
          # avoids truncating bigint values when casting from strings.
          class Unbounded < ActiveModel::Type::BigInteger
            def initialize(**)
              super(limit: 8, **)
            end
          end
        end
      end
    end
  end
end
