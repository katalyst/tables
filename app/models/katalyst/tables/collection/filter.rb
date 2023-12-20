# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      # Entry point for creating a collection for use with table components
      # where filter params are nested, e.g. ?filters[search]=query
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
      class Filter
        include Core
        include Filtering
        include Pagination
        include Sorting

        use(Sorting::Sort)
        use(Pagination::Paginate)

        def self.with_params(params)
          new.with_params(params)
        end

        def self.permitted_params
          super.excluding("sort", "page")
        end

        attr_reader :param_key

        def initialize(param_key: :filters, **options)
          super(**options)

          @param_key = param_key.to_sym
        end

        def model_name
          @model_name ||= items.model_name.tap do |name|
            name.param_key = param_key
          end
        end

        def with_params(params)
          params  = params.permit(:sort, :page, param_key => self.class.permitted_params)
          filters = params[param_key]

          self.attributes = filters if filters.present?
          self.attributes = params.slice("page", "sort")

          self
        end

        def to_params
          if filtered?
            { param_key.to_s => super.except("sort", "page") }.merge(super.slice("sort", "page"))
          else
            super.slice("sort", "page")
          end
        end

        def inspect
          "#<#{self.class.name} @param_key=#{param_key.inspect} " +
            "@attributes=#{attributes.inspect} @model=\"#{model}\" @count=#{items&.count}>"
        end
      end
    end
  end
end
