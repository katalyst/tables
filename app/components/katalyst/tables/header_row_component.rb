# frozen_string_literal: true

module Katalyst
  module Tables
    class HeaderRowComponent < ViewComponent::Base # :nodoc:
      include HasHtmlAttributes

      renders_many :columns, ->(component) { component }

      def initialize(table, link: {})
        super()

        @table           = table
        @link_attributes = link
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
        with_column(@table.class.header_cell_component.new(@table, attribute, link: @link_attributes, **options),
                    &block)
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
