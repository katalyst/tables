# frozen_string_literal: true

require_relative "builder/body_cell"
require_relative "builder/body_row"
require_relative "builder/header_cell"
require_relative "builder/header_row"

module Katalyst
  module Tables
    module Frontend
      # Builder API for generating HTML tables from ActiveRecord.
      # @see Frontend#table_with
      class TableBuilder
        attr_reader :template, :collection, :object_name, :sort

        def initialize(template, collection, options, html_options)
          @template     = template
          @collection   = collection
          @header       = options.fetch(:header, true)
          @object_name  = options.fetch(:object_name, nil)
          @sort         = options[:sort]
          @html_options = html_options
        end

        def table_header_row(builder = nil, &block)
          @template.table_header_row(self, builder || Builder::HeaderRow, &block)
        end

        def table_header_cell(method, builder = nil, **options, &block)
          @template.table_header_cell(self, method, builder || Builder::HeaderCell, **options, &block)
        end

        def table_body_row(object, builder = nil, &block)
          @template.table_body_row(self, object, builder || Builder::BodyRow, &block)
        end

        def table_body_cell(object, method, builder = nil, **options, &block)
          @template.table_body_cell(self, object, method, builder || Builder::BodyCell, **options, &block)
        end

        def build(&block)
          template.content_tag("table", @html_options) do
            thead(&block) + tbody(&block)
          end
        end

        private

        def thead(&block)
          return "".html_safe unless @header

          template.content_tag("thead") do
            table_header_row(&block)
          end
        end

        def tbody(&block)
          template.content_tag("tbody") do
            buffer = ActiveSupport::SafeBuffer.new

            collection.each do |object|
              buffer << table_body_row(object, &block)
            end

            buffer
          end
        end
      end
    end
  end
end
