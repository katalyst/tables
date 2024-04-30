# frozen_string_literal: true

module Katalyst
  module Tables
    module Body
      module TypedColumns
        extend ActiveSupport::Concern

        # Generates a column from boolean values rendered as "Yes" or "No".
        #
        # @param method [Symbol] the method to call on the record
        # @param attributes [Hash] HTML attributes to be added to the cell
        # @param block [Proc] optional block to alter the cell content
        # @return [void]
        #
        # @example Render a boolean column indicating whether the record is active
        #   <% row.boolean :active %> # => <td>Yes</td>
        def boolean(method, **attributes, &)
          with_column(Body::BooleanComponent.new(@table, @record, method, **attributes), &)
        end
      end
    end
  end
end
