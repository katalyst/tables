# frozen_string_literal: true

module Katalyst
  module Tables
    class HeaderCellComponent < ViewComponent::Base # :nodoc:
      include Frontend::Helper

      delegate :object_name, :sort, to: :@table

      def initialize(table, attribute, label: nil, **html_options)
        super(**html_options)

        @table        = table
        @attribute    = attribute
        @value        = label
      end

      def call
        content = if @table.sort&.supports?(@table.collection, @attribute)
                    sort_link(value) # writes to html_options
                  else
                    value
                  end

        tag.th(content, **@html_options)
      end

      def value
        if !@value.nil?
          @value
        elsif object_name.present?
          translation
        else
          default_value
        end
      end

      def translation(key = "activerecord.attributes.#{object_name}.#{@attribute}")
        translate(key, default: default_value)
      end

      def default_value
        @attribute.to_s.humanize.capitalize
      end

      private

      def sort_link(content)
        (@html_options["data"] ||= {})["sort"] = sort.status(@attribute)
        link_to(content, sort_url_for(sort: sort.toggle(@attribute)))
      end
    end
  end
end
