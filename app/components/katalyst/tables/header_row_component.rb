# frozen_string_literal: true

module Katalyst
  module Tables
    class HeaderRowComponent < ViewComponent::Base # :nodoc:
      include Katalyst::HtmlAttributes

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

      def cell(attribute, **, &)
        with_column(@table.header_cell_component.new(@table, attribute, link: @link_attributes, **), &)
      end

      def header?
        true
      end

      def body?
        false
      end

      def inspect
        "#<#{self.class.name} link_attributes: #{@link_attributes.inspect}>"
      end

      # Backwards compatibility with tables 1.0
      alias_method :options, :html_attributes=
    end
  end
end
