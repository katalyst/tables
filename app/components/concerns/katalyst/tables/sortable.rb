# frozen_string_literal: true

module Katalyst
  module Tables
    # Extension to add sorting support to a collection.
    # Assumes collection and sorting are available in the current scope.
    module Sortable
      extend ActiveSupport::Concern

      def initialize(**)
        super

        @header_row_cell_callbacks << method(:add_sorting_to_cell) if collection.sortable?
      end

      private

      def add_sorting_to_cell(cell)
        if collection.sortable?(cell.column)
          cell.update_html_attributes(data: { sort: collection.sort_status(cell.column) })
          cell.with_content_wrapper(SortableHeaderComponent.new(collection:, cell:))
        end
      end

      class SortableHeaderComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes

        attr_reader :collection, :cell

        delegate :column, to: :cell

        def initialize(collection:, cell:, **)
          super(**)

          @collection = collection
          @cell = cell
        end

        def call
          link_to(content, sort_url, **html_attributes)
        end

        # Generates a url for applying/toggling sort for the given column.
        def sort_url
          # rubocop:disable Metrics/AbcSize
          # Implementation inspired by pagy's `pagy_url_for` helper.
          # Preserve any existing GET parameters
          # CAUTION: these parameters are not sanitised
          sort = column && collection.toggle_sort(column)
          params = if sort && !sort.eql?(collection.default_sort)
                     request.GET.merge("sort" => sort).except("page")
                   else
                     request.GET.except("page", "sort")
                   end
          query_string = params.empty? ? "" : "?#{Rack::Utils.build_nested_query(params)}"

          "#{request.path}#{query_string}"
        end

        def default_html_attributes
          { class: "sortable", data: { turbo_action: "replace" } }
        end
      end
    end
  end
end
