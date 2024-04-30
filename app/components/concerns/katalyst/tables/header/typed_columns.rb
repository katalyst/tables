# frozen_string_literal: true

module Katalyst
  module Tables
    module Header
      module TypedColumns
        extend ActiveSupport::Concern

        # Renders a boolean column header
        # @param method [Symbol] the method to call on the record to get the value
        # @param attributes [Hash] additional arguments are applied as html attributes to the th element
        # @option attributes [String] :label (nil) The label options to display in the header
        # @option attributes [Hash] :link ({}) The link options for the sorting link
        #
        # @example Render a boolean column header
        #  <% row.boolean :active %> # => <th>Active</th>
        #
        # @example Render a boolean column header with a custom label
        #  <% row.boolean :active, label: "Published" %> # => <th>Published</th>
        def boolean(method, **attributes, &)
          with_column(Header::BooleanComponent.new(@table, method, link: @link_attributes, **attributes), &)
        end
      end
    end
  end
end
