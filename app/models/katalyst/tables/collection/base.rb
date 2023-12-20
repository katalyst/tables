# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      # Entry point for creating a collection for use with table components
      # where filter params are flat, e.g. ?search=query
      #
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
        include Filtering
        include Pagination
        include Sorting

        use(Sorting::Sort)
        use(Pagination::Paginate)

        def self.with_params(params)
          new.with_params(params)
        end

        def model_name
          @model_name ||= items.model_name.dup.tap do |name|
            name.param_key = ""
          end
        end

        def with_params(params)
          # test support
          params = ActionController::Parameters.new(params) unless params.is_a?(ActionController::Parameters)

          self.attributes = params.permit(self.class.permitted_params)

          self
        end

        def inspect
          "#<#{self.class.name} @attributes=#{attributes.inspect} @model_name=\"#{model_name}\" @count=#{items&.count}>"
        end
      end
    end
  end
end
