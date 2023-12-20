# frozen_string_literal: true

module Katalyst
  module Tables
    # Extension to add sorting support to a collection.
    # Assumes collection and sorting are available in the current scope.
    module Sortable
      extend ActiveSupport::Concern

      refine ActiveRecord::Relation do
        def sortable?
          false
        end
      end

      def sortable?(attribute)
        collection.sortable?(attribute)
      end

      def sorting_state(attribute)
        collection.sorting_state(attribute)
      end

      # Generates a url for applying/toggling sort for the given column.
      def sort_url(attribute) # rubocop:disable Metrics/AbcSize
        # Implementation inspired by pagy's `pagy_url_for` helper.
        # Preserve any existing GET parameters
        # CAUTION: these parameters are not sanitised
        sort = attribute && collection.toggle_sort(attribute)
        params = if sort && !sort.eql?(collection.default_sort)
                   request.GET.merge("sort" => sort).except("page")
                 else
                   request.GET.except("page", "sort")
                 end
        query_string = params.empty? ? "" : "?#{Rack::Utils.build_nested_query(params)}"

        "#{request.path}#{query_string}"
      end
    end
  end
end
