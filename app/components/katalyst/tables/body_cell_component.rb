# frozen_string_literal: true

module Katalyst
  module Tables
    class BodyCellComponent < ViewComponent::Base # :nodoc:
      include Frontend::Helper

      attr_reader :record

      def initialize(table, record, attribute, heading: false, **html_options)
        super(**html_options)

        @table     = table
        @record    = record
        @attribute = attribute
        @type      = heading ? :th : :td
      end

      def before_render
        # fallback if no content block is given
        with_content(value.to_s) unless content?
      end

      def call
        content # ensure content is set before rendering options

        content_tag(@type, content, **@html_options)
      end

      # @return the object for this row.
      def object
        @record
      end

      def value
        @record.public_send(@attribute)
      end
    end
  end
end
