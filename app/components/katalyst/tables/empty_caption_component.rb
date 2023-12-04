# frozen_string_literal: true

module Katalyst
  module Tables
    class EmptyCaptionComponent < ViewComponent::Base # :nodoc:
      include Katalyst::HtmlAttributes

      def initialize(table, **html_attributes)
        super(**html_attributes)

        @table = table
      end

      def render?
        @table.collection.empty?
      end

      def filtered?
        @table.collection.respond_to?(:filtered?) && @table.collection.filtered?
      end

      def clear_filters_path
        url_for
      end

      def plural_human_model_name
        human = @table.model_name&.human || @table.object_name.to_s.humanize
        human.pluralize.downcase
      end

      def inspect
        "#<#{self.class.name}>"
      end

      private

      def default_html_attributes
        { align: "bottom" }
      end
    end
  end
end
