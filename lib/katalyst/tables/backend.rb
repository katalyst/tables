require_relative "backend/sort_form"

module Katalyst::Tables
  module Backend
    def sort(collection)
      column, direction = params[:sort]&.split(" ")
      direction         = SortForm::DIRECTIONS.include?(direction) ? direction : "asc"

      SortForm.new(self, column: column, direction: direction).apply(collection)
    end
  end
end
