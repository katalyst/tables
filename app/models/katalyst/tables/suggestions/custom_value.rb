# frozen_string_literal: true

module Katalyst
  module Tables
    module Suggestions
      class CustomValue < Base
        delegate :to_param, to: :@attribute_type

        def initialize(value, name:, type:)
          super(value)

          @name = name
          @attribute_type = type
        end

        def type
          :custom_value
        end

        def value
          to_param(@value)
        end
      end
    end
  end
end
