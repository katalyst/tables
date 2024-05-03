# frozen_string_literal: true

using Katalyst::HtmlAttributes::HasHtmlAttributes

module Katalyst
  module Tables
    class HeaderCellComponent < ViewComponent::Base # :nodoc:
      include Frontend::Helper
      include Katalyst::HtmlAttributes
      include Sortable

      delegate :object_name, :collection, :sorting, to: :@table

      def initialize(table, attribute, label: nil, link: {}, width: nil, **html_attributes)
        super(**html_attributes)

        @table           = table
        @attribute       = attribute
        @value           = label
        @width           = width
        @link_attributes = link
      end

      def call
        tag.th(**html_attributes) do
          if sortable?(@attribute)
            link_to(value, sort_url(@attribute), **link_attributes)
          else
            value
          end
        end
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

      def inspect
        "#<#{self.class.name} attribute: #{@attribute.inspect}, value: #{@value.inspect}>"
      end

      # Backwards compatibility with tables 1.0
      alias_method :options, :html_attributes=

      private

      def width_class
        case @width
        when :xs
          "width-xs"
        when :s
          "width-s"
        when :m
          "width-m"
        when :l
          "width-l"
        else
          ""
        end
      end

      def link_attributes
        { data: { turbo_action: "replace" } }.merge_html(@link_attributes)
      end

      def default_html_attributes
        sort_data.merge(width_data)
      end

      def width_data
        return {} unless @width

        { class: width_class }
      end

      def sort_data
        return {} unless sorting&.supports?(collection, @attribute)

        { data: { sort: sorting.status(@attribute) } }
      end
    end
  end
end
