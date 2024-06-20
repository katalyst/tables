# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Integer < Value
          delegate :type, :serialize, :deserialize, :cast, to: :@delegate

          def initialize(...)
            super

            @delegate = ActiveModel::Type::Integer.new
          end
        end
      end
    end
  end
end
