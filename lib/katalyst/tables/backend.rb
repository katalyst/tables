require_relative "backend/sort_form"

module Katalyst::Tables
  # Utilities for controllers that are generating collections for visualisation
  # in a table view using Katalyst::Tables::Frontend.
  #
  # Provides `table_sort` for sorting based on column interactions (sort param).
  module Backend
    # Sort the given collection by params[:sort], which is set when a user
    # interacts with a column header in a frontend table view.
    #
    # @return [[SortForm, ActiveRecord::Relation]]
    def table_sort(collection)
      column, direction = params[:sort]&.split(" ")
      direction         = SortForm::DIRECTIONS.include?(direction) ? direction : "asc"

      SortForm.new(self,
                   column: column,
                   direction: direction)
              .apply(collection)
    end
  end
end
