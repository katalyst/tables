# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Float < Value
          include Helpers::Delegate
          include Helpers::Multiple

          def initialize(**)
            super(**, delegate: ActiveModel::Type::Float)
          end

          def serialize(value)
            if value.is_a?(Range)
              if value.begin.nil?
                "<#{super(value.end)}"
              elsif value.end.nil?
                ">#{super(value.begin)}"
              else
                "#{super(value.begin)}..#{super(value.end)}"
              end
            else
              super
            end
          end

          private

          FLOAT = /(-?\d+(?:\.\d+)?)/
          SINGLE_VALUE = /\A#{FLOAT}\z/
          LOWER_BOUND = /\A>#{FLOAT}\z/
          UPPER_BOUND = /\A<#{FLOAT}\z/
          BOUNDED = /\A#{FLOAT}\.\.#{FLOAT}\z/

          def cast_value(value)
            case value
            when ::Range, ::Integer
              value
            when SINGLE_VALUE
              super($1)
            when LOWER_BOUND
              ((super($1))..)
            when UPPER_BOUND
              (..(super($1)))
            when BOUNDED
              ((super($1))..(super($2)))
            else
              super
            end
          end
        end
      end
    end
  end
end
