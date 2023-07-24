# frozen_string_literal: true

module Katalyst
  module Tables
    module Frontend
      module Helper # :nodoc:
        extend ActiveSupport::Concern

        # Generates a url for applying/toggling sort for the given column.
        #
        # @param sort [String, nil] sort parameter to apply, or nil to remove sorting
        # @return [String] URL for toggling column sorting
        def sort_url_for(sort: nil)
          # Implementation inspired by pagy's `pagy_url_for` helper.
          # Preserve any existing GET parameters
          # CAUTION: these parameters are not sanitised
          params = if sort
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
end
