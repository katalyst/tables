# frozen_string_literal: true

module Katalyst
  module Tables
    class BodyRowComponent < ViewComponent::Base # :nodoc:
      include Katalyst::HtmlAttributes

      renders_many :columns, ->(component) { component }

      def initialize(table, record)
        super()

        @table  = table
        @record = record
      end

      def call
        content # generate content before rendering

        tag.tr(**html_attributes) do
          columns.each do |column|
            concat(column.to_s)
          end
        end
      end

      def cell(attribute, **options, &block)
        with_column(@table.body_cell_component.new(@table, @record, attribute, **options), &block)
      end

      def header?
        false
      end

      def body?
        true
      end

      def inspect
        "#<#{self.class.name} record: #{record.inspect}>"
      end

      # Backwards compatibility with tables 1.0
      alias_method :options, :html_attributes=
    end
  end
end
