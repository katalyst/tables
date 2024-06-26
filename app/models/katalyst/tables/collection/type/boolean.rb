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
            return false unless filterable?

            if attribute.came_from_user?
              attribute.value_before_type_cast.present? || value === false
            else
              !value.nil? && !value.eql?([])
            end
          end
        end
      end
    end
  end
end
