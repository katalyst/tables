# frozen_string_literal: true

module Katalyst
  module Tables
    class BodyRowComponent < ViewComponent::Base # :nodoc:
      include HasHtmlAttributes

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
    end
  end
end
