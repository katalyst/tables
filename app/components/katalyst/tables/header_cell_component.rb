# frozen_string_literal: true

module Katalyst
  module Tables
    class HeaderCellComponent < ViewComponent::Base # :nodoc:
      include Frontend::Helper
      include HasHtmlAttributes

      delegate :object_name, :sorting, to: :@table

      def initialize(table, attribute, label: nil, link: {}, **html_attributes)
        super(**html_attributes)

        @table           = table
        @attribute       = attribute
        @value           = label
        @link_attributes = link
      end

      def call
        content = if @table.sorting&.supports?(@table.collection, @attribute)
                    sort_link(value) # writes to html_attributes
                  else
                    value
                  end

        tag.th(content, **html_attributes)
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
        (@html_attributes[:data] ||= {})[:sort] = sorting.status(@attribute)
        link_to(content, sort_url_for(sort: sorting.toggle(@attribute)), **@link_attributes)
      end
    end
  end
end
