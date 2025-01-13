# frozen_string_literal: true

module Katalyst
  module Tables
    module Suggestions
      class DatabaseValue < Base
        delegate :to_param, to: :@attribute_type

        def initialize(name:, type:, value:)
          super(value)

          @attribute_type = type
          @name = name
        end

        def type
          :database_value
        end

        using Tables::Collection::Type::Helpers::Extensions

        def value
          if @attribute_type.multiple? && @value.is_a?(Array) && @value.length == 1
            to_param(@value.first)
          else
            to_param(@value)
          end
        end
      end
    end
  end
end
