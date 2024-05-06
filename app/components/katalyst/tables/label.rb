# frozen_string_literal: true

module Katalyst
  module Tables
    class Label
      def initialize(collection:, column:, label: nil)
        @collection = collection
        @column = column
        @label = label
      end

      def value
        return @value if defined?(@value)

        @value = if !@label.nil?
                   @label
                 elsif @collection.model.present?
                   @collection.model.human_attribute_name(@column)
                 else
                   @column.to_s.humanize.capitalize
                 end
      end

      def call
        ActionView::OutputBuffer.new.tap do |output|
          output << value.to_s
        end.to_s
      end

      alias to_s call

      def inspect
        "#<#{self.class.name} column: #{@column.inspect} value: #{value.inspect}>"
      end
    end
  end
end
