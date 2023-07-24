# frozen_string_literal: true

require "pagy/backend"

module Katalyst
  module Tables
    module Collection
      # Adds sorting support to a collection.
      #
      # Sorting will be applied if the collection is configured with a default
      # sorting configuration by either specifying
      # `config.sorting = "column direction"` or passing
      # `sorting: "column direction"` to the initializer.
      #
      # If `sort` is present in params it will override the default sorting.
      module Sorting
        extend ActiveSupport::Concern

        included do
          config_accessor :sorting
          attr_accessor :sorting

          attribute :sort, :string
        end

        def initialize(sorting: config.sorting, **options)
          @sorting = Backend::SortForm.parse(sorting) if sorting

          super(sort: sorting, **options) # set default sort based on config
        end

        def sort=(value)
          return unless @sorting

          # update internal proxy
          @sorting = Backend::SortForm.parse(value, default: attribute_was(:sort))

          # update attribute based on normalized value
          super(@sorting.to_param)
        end

        class Sort # :nodoc:
          include Backend

          def initialize(app)
            @app = app
          end

          def call(collection)
            @collection                            = @app.call(collection)
            @collection.sorting, @collection.items = @collection.sorting.apply(@collection.items) if @collection.sorting
            @collection
          end

          # pagy shim
          def params
            @collection.attributes
          end
        end
      end
    end
  end
end
