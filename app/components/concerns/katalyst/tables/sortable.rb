# frozen_string_literal: true

module Katalyst
  module Tables
    # Extension to add sorting support to a collection.
    # Assumes collection and sorting are available in the current scope.
    module Sortable
      extend ActiveSupport::Concern

      # Returns true when the given attribute is sortable.
      def sortable?(attribute)
        sorting&.supports?(collection, attribute)
      end

      # Generates a url for applying/toggling sort for the given column.
      def sort_url(attribute) # rubocop:disable Metrics/AbcSize
        # Implementation inspired by pagy's `pagy_url_for` helper.
        # Preserve any existing GET parameters
        # CAUTION: these parameters are not sanitised
        sort = attribute && sorting.toggle(attribute)
        params = if sort && !sort.eql?(sorting.default)
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
