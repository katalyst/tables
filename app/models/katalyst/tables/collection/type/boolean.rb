# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Boolean < Value
          delegate :type, :serialize, :deserialize, :cast, to: :@delegate

          def initialize(...)
            super

            @delegate = ActiveModel::Type::Boolean.new
          end

          def filter?(attribute, value)
            !value.nil? || attribute.came_from_user?
          end
        end
      end
    end
  end
end
