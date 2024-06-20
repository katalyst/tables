# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Boolean < Value
          include Helpers::Delegate
          include Helpers::Multiple

          def initialize(**)
            super(**, delegate: ActiveModel::Type::Boolean)
          end

          def filter?(attribute, value)
            !value.nil? || attribute.came_from_user?
          end
        end
      end
    end
  end
end
