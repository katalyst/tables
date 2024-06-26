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
            super(**, delegate: ActiveModel::Type::Integer)
          end
        end
      end
    end
  end
end
