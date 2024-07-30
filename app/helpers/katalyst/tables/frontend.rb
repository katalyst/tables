# frozen_string_literal: true

module Katalyst
  module Tables
    # View Helper for generating HTML tables. Include in your ApplicationHelper, or similar.
    module Frontend
      # Construct a new table component. This entry point supports a large number
      # of options for customizing the table. The most common options are:
      # @param collection [Katalyst::Tables::Collection::Core] the collection to render
      # @param header [Boolean] whether to render the header row (defaults to true, supports options)
      # @param caption [Boolean Hash] whether to render the caption (defaults to true, supports options)
      # @param generate_ids [Boolean] whether to generate dom ids for the table and rows
      #
      # Blocks will receive the table in row-rendering mode (with row and record defined):
      # @yieldparam [Katalyst::TableComponent] the row component to render
      # @yieldparam [Object, nil] the object to render, or nil for header rows
      #
      # If no block is provided when the table is rendered then the table will look for a row partial:
      # @param object_name [Symbol] the name of the object to use for partial rendering
      #        (defaults to collection.model_name.i18n_key)
      # @param partial [String] the name of the partial to use for rendering each row
      #        (defaults to to_partial_path on the object)
      # @param as [Symbol] the name of the local variable to use for rendering each row
      #        (defaults to collection.model_name.param_key)
      #
      # In addition to these options, standard HTML attributes can be passed which will be added to the table tag.
      def table_with(collection:,
                     component: nil,
                     header: true,
                     caption: true,
                     generate_ids: false,
                     object_name: nil,
                     partial: nil,
                     as: nil,
                     **,
                     &)
        component ||= default_table_component_class
        component = component.new(collection:, header:, caption:, generate_ids:, object_name:, partial:, as:, **)

        render(component, &)
      end

      # @param collection [Katalyst::Tables::Collection::Core] the collection to render
      # @param url [String] the url to submit the form to (e.g. <resources>_order_path)
      # @param id [String] the id of the form element (defaults to <resources>_order_form)
      # @param scope [String] the base scope to use for form inputs (defaults to order[<resources>])
      def table_orderable_with(collection:, url:, id: nil, scope: nil, &)
        render(Orderable::FormComponent.new(collection:, url:, id:, scope:))
      end

      # @param collection [Katalyst::Tables::Collection::Core] the collection to render
      # @param id [String] the id of the form element (defaults to <resources>_selection_form)
      # @param primary_key [String] the primary key of the record in the collection (defaults to :id)
      def table_selection_with(collection:, id: nil, primary_key: :id, &)
        render(Selectable::FormComponent.new(collection:, id:, primary_key:), &)
      end

      # Construct pagination navigation for the current page. Defaults to pagy_nav.
      #
      # @param collection [Katalyst::Tables::Collection::Core] the collection to render
      def table_pagination_with(collection:, **)
        component ||= default_table_pagination_component_class
        render(component.new(collection:, **))
      end

      # Construct a new query interface for filtering the current page.
      #
      # @param collection [Katalyst::Tables::Collection::Core] the collection to render
      # @param url [String] the url to submit the form to (e.g. <resources>_path)
      def table_query_with(collection:, url: url_for, component: nil, &)
        component ||= default_table_query_component_class
        render(component.new(collection:, url:), &)
      end

      # Construct a new summary table component.
      #
      # @param model [ActiveRecord::Base] subject for the table
      #
      # Blocks will receive the table in row-rendering mode (with row and record defined):
      # @yieldparam [Katalyst::TableComponent] the table component to render rows
      # @yieldparam [nil, Object] nil for the header column, or the given model for the value column
      def summary_table_with(model:, **, &)
        component ||= default_summary_table_component_class
        component = component.new(model:, **)

        render(component, &)
      end

      private

      def default_table_component_class
        component = controller.try(:default_table_component) || TableComponent
        component.respond_to?(:constantize) ? component.constantize : component
      end

      def default_table_pagination_component_class
        component = controller.try(:default_table_pagination_component) || PagyNavComponent
        component.respond_to?(:constantize) ? component.constantize : component
      end

      def default_table_query_component_class
        component = controller.try(:default_table_query_component) || QueryComponent
        component.respond_to?(:constantize) ? component.constantize : component
      end

      def default_summary_table_component_class
        component = controller.try(:default_summary_table_component) || SummaryTableComponent
        component.respond_to?(:constantize) ? component.constantize : component
      end
    end
  end
end
