# frozen_string_literal: true

require_relative "body_cell"

module Katalyst
  module Tables
    module Frontend
      module Builder
        class HeaderCell < BodyCell # :nodoc:
          def initialize(table, method, **options)
            super(table, nil, method, **options)

            @value  = options[:label]
            @header = true
          end

          def build(&_block)
            # NOTE: block ignored intentionally but subclasses may consume it
            if @table.sort&.supports?(@table.collection, method)
              content = sort_link(value) # writes to html_options
              table_tag :th, content # consumes options
            else
              table_tag :th, value
            end
          end

          def value
            if !@value.nil?
              @value
            elsif @table.object_name.present?
              translation
            else
              default_value
            end
          end

          def translation(key = "activerecord.attributes.#{@table.object_name}.#{method}")
            translate(key, default: default_value)
          end

          def default_value
            method.to_s.humanize.titleize
          end

          private

          def sort_link(content)
            (@html_options["data"] ||= {})["sort"] = sort.status(method)
            link_to(content, sort_url_for(sort: sort.toggle(method)))
          end
        end
      end
    end
  end
end
