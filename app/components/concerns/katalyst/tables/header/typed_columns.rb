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

        # Renders a date column header
        # @param method [Symbol] the method to call on the record to get the value
        # @param attributes [Hash] additional arguments are applied as html attributes to the th element
        # @option attributes [String] :label (nil) The label options to display in the header
        # @option attributes [Hash] :link ({}) The link options for the sorting link
        #
        # @example Render a date column header
        #  <% row.date :published_on %> # => <th>Published on</th>
        #
        # @example Render a date column header with a custom label
        #  <% row.date :published_on, label: "Date" %> # => <th>Date</th>
        def date(method, **attributes, &)
          with_column(Header::DateComponent.new(@table, method, link: @link_attributes, **attributes), &)
        end

        # Renders a datetime column header
        # @param method [Symbol] the method to call on the record to get the value
        # @param attributes [Hash] additional arguments are applied as html attributes to the th element
        # @option attributes [String] :label (nil) The label options to display in the header
        # @option attributes [Hash] :link ({}) The link options for the sorting link
        #
        # @example Render a datetime column header
        #  <% row.datetime :created_at %> # => <th>Created at</th>
        #
        # @example Render a datetime column header with a custom label
        #  <% row.datetime :created_at, label: "Published at" %> # => <th>Published at</th>
        def datetime(method, **attributes, &)
          with_column(Header::DateTimeComponent.new(@table, method, link: @link_attributes, **attributes), &)
        end

        # Renders a number column header
        # @param method [Symbol] the method to call on the record to get the value
        # @param attributes [Hash] additional arguments are applied as html attributes to the th element
        # @option attributes [String] :label (nil) The label options to display in the header
        # @option attributes [Hash] :link ({}) The link options for the sorting link
        #
        # @example Render a number column header
        #  <% row.number :comment_count %> # => <th>Comments</th>
        #
        # @example Render a number column header with a custom label
        #  <% row.number :comment_count, label: "Comments" %> # => <th>Comments</th>
        def number(method, **attributes, &)
          with_column(Header::NumberComponent.new(@table, method, link: @link_attributes, **attributes), &)
        end

        # Renders a currency column header
        # @param method [Symbol] the method to call on the record to get the value
        # @param attributes [Hash] additional arguments are applied as html attributes to the th element
        # @option attributes [String] :label (nil) The label options to display in the header
        # @option attributes [Hash] :link ({}) The link options for the sorting link
        #
        # @example Render a currency column header
        #  <% row.currency :price %> # => <th>Price</th>
        #
        # @example Render a currency column header with a custom label
        #  <% row.currency :price, label: "Amount($)" %> # => <th>Amount($)</th>
        def currency(method, **attributes, &)
          with_column(Header::CurrencyComponent.new(@table, method, link: @link_attributes, **attributes), &)
        end

        # Renders a rich text column header
        # @param method [Symbol] the method to call on the record to get the value
        # @param attributes [Hash] additional arguments are applied as html attributes to the th element
        # @option attributes [String] :label (nil) The label options to display in the header
        # @option attributes [Hash] :link ({}) The link options for the sorting link
        #
        # @example Render a rich text header
        #  <% row.rich_text :content %> # => <th>Content</th>
        #
        # @example Render a rich text column header with a custom label
        #  <% row.currency :content, label: "Content!" %> # => <th>Content!</th>
        def rich_text(method, **attributes, &)
          with_column(Header::RichTextComponent.new(@table, method, link: @link_attributes, **attributes), &)
        end
      end
    end
  end
end
