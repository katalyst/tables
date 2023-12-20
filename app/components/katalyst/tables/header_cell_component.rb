# frozen_string_literal: true

module Katalyst
  module Tables
    class HeaderCellComponent < ViewComponent::Base # :nodoc:
      include Katalyst::HtmlAttributes
      include Sortable

      delegate :object_name, :collection, to: :@table

      def initialize(table, attribute, label: nil, link: {}, **html_attributes)
        super(**html_attributes)

        @table           = table
        @attribute       = attribute
        @value           = label
        @link_attributes = link
      end

      def call
        tag.th(**html_attributes) do
          if sortable?(@attribute)
            link_to(value, sort_url(@attribute), **@link_attributes)
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
        "#<#{self.class.name} attribute: #{@attribute.inspect}, value: #{value.inspect}>"
      end

      # Backwards compatibility with tables 1.0
      alias_method :options, :html_attributes=

      private

      def default_html_attributes
        return {} unless sortable?(@attribute)

        { data: { sort: sorting_state(@attribute) } }
      end
    end
  end
end
