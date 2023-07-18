# frozen_string_literal: true

module Katalyst
  module Tables
    class HeaderRowComponent < ViewComponent::Base # :nodoc:
      include Frontend::Helper

      renders_many :columns, ->(component) { component }

      def initialize(table)
        super()

        @table = table
      end

      def call
        content # generate content before rendering

        tag.tr(**@html_options) do
          columns.each do |column|
            concat(column.to_s)
          end
        end
      end

      def cell(attribute, **options, &block)
        with_column(@table.class.header_cell_component.new(@table, attribute, **options), &block)
      end

      def header?
        true
      end

      def body?
        false
      end
    end
  end
end
