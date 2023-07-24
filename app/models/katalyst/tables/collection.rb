# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      # Entry point for creating a collection for use with table components.
      # This class is intended to be subclassed, i.e.:
      #
      # class ApplicationController < ActionController::Base
      #   class Collection < Katalyst::Tables::Collection::Base
      #     ...
      #   end
      # end
      #
      # In the context of a controller action, construct a collection, apply it
      # to a model, then pass the result to the view component:
      # ```
      # collection = Collection.new.with_params(params).apply(People.all)
      # table = Katalyst::TableComponent.new(collection: collection)
      # render table
      # ````
      class Base
        include Core
        include Pagination
        include Sorting

        use(Pagination::Paginate)
        use(Sorting::Sort)
      end
    end
  end
end
