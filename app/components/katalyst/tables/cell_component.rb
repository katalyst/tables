# frozen_string_literal: true

module Katalyst
  module Tables
    class CellComponent < ViewComponent::Base # :nodoc:
      include Katalyst::HtmlAttributes

      attr_reader :collection, :row, :column, :record

      def initialize(collection:, row:, column:, record:, label:, heading:, **)
        super(**)

        @collection = collection
        @row = row
        @column = column
        @record = record
        @heading = heading

        if @row.header?
          @label = Label.new(collection:, column:, label:)
        else
          @data = Data.new(record:, column:)
        end
      end

      # @return true if the cell is a heading cell (th).
      def heading?
        @row.header? || @heading
      end

      # Adds a component to wrap the content of the cell, similar to a layout in Rails views.
      def with_content_wrapper(component)
        @content_wrapper = component

        self
      end

      def call
        content = if content?
                    self.content
                  elsif @row.header?
                    label
                  else
                    rendered_value
                  end

        content = @content_wrapper.with_content(content).render_in(view_context) if @content_wrapper

        concat(content_tag(cell_tag, content, **html_attributes))
      end

      # Return the rendered and sanitized label for the column.
      def label
        @label&.to_s
      end

      # Return the raw value of the cell (i.e. the value of the data read from the record)
      def value
        @data&.value
      end

      # Return the serialized and sanitised data value for rendering in the cell.
      def rendered_value
        @data&.to_s
      end

      # Serialize data for use in blocks, i.e.
      #   row.cell(:name) { |cell| tag.span(cell) }
      def to_s
        # Note, this can't be `content` because the block is evaluated in order to produce content.
        rendered_value
      end

      def inspect
        "#<#{self.class.name} method: #{@method.inspect}>"
      end

      private

      def cell_tag
        heading? ? :th : :td
      end
    end
  end
end
