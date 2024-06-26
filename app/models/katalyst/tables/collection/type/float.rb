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
        end
      end
    end
  end
end
