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
      def table_with(collection:,
                     builder: nil,
                     object_name: collection.try(:model_name)&.i18n_key,
                     **options, &block)
        builder ||= default_table_builder_class
        builder.new(self, collection, object_name: object_name, **options).build(&block)
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
