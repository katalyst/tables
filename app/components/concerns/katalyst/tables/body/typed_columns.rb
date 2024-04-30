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

        # Generates a column from date values rendered using I18n.l.
        # The default format is :admin, but it can be overridden.
        #
        # @param method [Symbol] the method to call on the record
        # @param format [Symbol] the I18n date format to use when rendering
        # @param attributes [Hash] HTML attributes to be added to the cell tag
        # @param block [Proc] optional block to alter the cell content
        # @return [void]
        #
        # @example Render a date column describing when the record was created
        #   <% row.date :created_at %> # => <td>29 Feb 2024</td>
        def date(method, format: :table, **attributes, &)
          with_column(Body::DateComponent.new(@table, @record, method, format:, **attributes), &)
        end

        # Generates a column from datetime values rendered using I18n.l.
        # The default format is :admin, but it can be overridden.
        #
        # @param method [Symbol] the method to call on the record
        # @param format [Symbol] the I18n datetime format to use when rendering
        # @param attributes [Hash] HTML attributes to be added to the cell tag
        # @param block [Proc] optional block to alter the cell content
        # @return [void]
        #
        # @example Render a datetime column describing when the record was created
        #   <% row.datetime :created_at %> # => <td>29 Feb 2024, 5:00pm</td>
        def datetime(method, format: :table, **attributes, &)
          with_column(Body::DateTimeComponent.new(@table, @record, method, format:, **attributes), &)
        end

        # Generates a column from numeric values formatted appropriately.
        #
        # @param method [Symbol] the method to call on the record
        # @param attributes [Hash] HTML attributes to be added to the cell tag
        # @param block [Proc] optional block to alter the cell content
        # @return [void]
        #
        # @example Render the number of comments on a post
        #   <% row.number :comment_count %> # => <td>0</td>
        def number(method, **attributes, &)
          with_column(Body::NumberComponent.new(@table, @record, method, **attributes), &)
        end
      end
    end
  end
end
