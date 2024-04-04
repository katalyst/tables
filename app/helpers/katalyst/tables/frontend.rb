# frozen_string_literal: true

module Katalyst
  module Tables
    # View Helper for generating HTML tables. Include in your ApplicationHelper, or similar.
    module Frontend
      def table_with(collection:, component: nil, **, &)
        component ||= default_table_component_class
        render(component.new(collection:, **), &)
      end

      private

      def default_table_component_class
        component = controller.try(:default_table_component) || TableComponent
        component.respond_to?(:constantize) ? component.constantize : component
      end
    end
  end
end
