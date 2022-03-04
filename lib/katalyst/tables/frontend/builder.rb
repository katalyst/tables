# frozen_string_literal: true

require_relative "helper"

module Katalyst
  module Tables
    module Frontend
      # Builder API for generating HTML tables from ActiveRecord.
      # @see Frontend#table_with
      class Builder
        attr_reader :template, :collection, :object_name, :sort

        def initialize(template, collection, options, html_options)
          @template     = template
          @collection   = collection
          @header       = options.fetch(:header, true)
          @object_name  = options.fetch(:object_name, nil)
          @sort         = options[:sort]
          @html_options = html_options
        end

        def build(&block)
          @template.content_tag("table", @html_options) do
            header(&block) + body(&block)
          end
        end

        private

        def header(&block)
          return "".html_safe unless @header

          @template.content_tag("thead") do
            Header::Row.new(self).build(&block)
          end
        end

        def body(&block)
          @template.content_tag("tbody") do
            buffer = ActiveSupport::SafeBuffer.new

            collection.each do |object|
              buffer << row(object, &block)
            end

            buffer
          end
        end

        def row(object, &block)
          Body::Row.new(self, object).build(&block)
        end

        class Tag # :nodoc:
          include Helper

          def initialize(table, **options)
            @table  = table
            @header = false
            self.options(**options)
          end

          def header?
            @header
          end

          def body?
            !@header
          end

          def options(**options)
            @html_options = html_options_for_table_with(**options)
          end

          private

          def tag(type, value = nil, &block)
            # capture output before calling tag, to allow users to modify `options` during body execution
            value = @table.template.with_output_buffer(&block) if block_given?

            @table.template.content_tag(type, value, @html_options, &block)
          end
        end

        module Body
          class Row < Tag # :nodoc:
            attr_reader :object

            def initialize(table, object, cell = Cell)
              super table

              @cell   = cell
              @object = object
            end

            def build
              tag(:tr) { yield self, object }
            end

            def cell(method, **options, &block)
              @cell.new(@table, object, method, **options).build(&block)
            end
          end

          class Cell < Tag # :nodoc:
            attr_reader :object, :method

            def initialize(table, object, method, **options)
              super table, **options

              @type   = options.fetch(:heading, false) ? :th : :td
              @object = object
              @method = method
            end

            def build
              tag(@type) { block_given? ? yield(self).to_s : value.to_s }
            end

            def value
              object.public_send(method)
            end
          end
        end

        module Header
          class Row < Body::Row # :nodoc:
            def initialize(table)
              super table, nil, Cell

              @header = true
            end
          end

          class Cell < Body::Cell # :nodoc:
            def initialize(table, object, method, **options)
              super

              @value  = options[:label]
              @header = true
            end

            def build
              if @table.sort&.supports?(@table.collection, method)
                content = sort_link(value) # writes to html_options
                tag :th, content # consumes options
              else
                tag :th, value
              end
            end

            def value
              if @value.present?
                @value
              elsif @table.object_name.present?
                translation
              else
                default_value
              end
            end

            def translation(key = "activerecord.attributes.#{@table.object_name}.#{method}")
              @table.template.translate(key, default: default_value)
            end

            def default_value
              method.to_s.humanize.titleize
            end

            private

            def sort_link(content)
              (@html_options["data"] ||= {})["sort"] = @table.sort.status(method)
              @table.template.link_to(content, @table.sort.url_for(method))
            end
          end
        end
      end
    end
  end
end
