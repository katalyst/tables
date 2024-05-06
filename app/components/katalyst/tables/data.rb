# frozen_string_literal: true

module Katalyst
  module Tables
    class Data
      def initialize(record:, column:)
        @record = record
        @column = column
      end

      def value
        return @value if defined?(@value)

        @value = @record&.public_send(@column)
      end

      def call
        ActionView::OutputBuffer.new.tap do |output|
          output << value.to_s
        end.to_s
      end

      alias to_s call

      def inspect
        "#<#{self.class.name} column: #{@column.inspect}, value: #{value.inspect}>"
      end
    end
  end
end
