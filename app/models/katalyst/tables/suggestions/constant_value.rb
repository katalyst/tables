# frozen_string_literal: true

module Katalyst
  module Tables
    module Suggestions
      class ConstantValue < Base
        delegate :to_param, to: :@attribute_type

        def initialize(name:, type:, value:)
          super(value)

          @attribute_type = type
          @name = name
        end

        def type
          :constant_value
        end

        def value
          to_param(@value)
        end
      end
    end
  end
end
