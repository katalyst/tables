# frozen_string_literal: true

require_relative "frontend/builder/base"
require_relative "frontend/builder/body_cell"
require_relative "frontend/builder/body_row"
require_relative "frontend/builder/header_cell"
require_relative "frontend/builder/header_row"
require_relative "frontend/helper"
require_relative "frontend/table_builder"

module Katalyst
  module Tables
    # View Helper for generating HTML tables. Include in your ApplicationHelper, or similar.
    module Frontend
      include Helper

      def table_with(collection:, **options, &block)
        table_options = options.slice(:header, :object_name, :sort)

        table_options[:object_name] ||= collection.try(:model_name)&.i18n_key

        html_options = html_options_for_table_with(**options)

        builder = options.fetch(:builder) { default_table_builder_class }
        builder.new(self, collection, table_options, html_options).build(&block)
      end

      def table_header_row(table, builder, &block)
        builder.new(table).build(&block)
      end

      def table_header_cell(table, method, builder, **options, &block)
        builder.new(table, method, **options).build(&block)
      end

      def table_body_row(table, object, builder, &block)
        builder.new(table, object).build(&block)
      end

      def table_body_cell(table, object, method, builder, **options, &block)
        builder.new(table, object, method, **options).build(&block)
      end

      private

      def default_table_builder_class
        builder = controller.try(:default_table_builder) || TableBuilder
        builder.respond_to?(:constantize) ? builder.constantize : builder
      end
    end
  end
end
