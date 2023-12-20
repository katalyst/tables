# frozen_string_literal: true

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
          @sorting = SortForm.parse(sorting) if sorting

          super(sort: sorting, **options) # set default sort based on config
        end

        def sortable?(attribute)
          @sorting&.supports?(self, attribute)
        end

        def sorting_state(attribute)
          @sorting&.status(attribute)
        end

        def toggle_sort(attribute)
          @sorting&.toggle(attribute)
        end

        def default_sort
          @sorting&.default
        end

        def sort=(value)
          return unless @sorting

          # update internal proxy
          @sorting = SortForm.parse(value, default: attribute_was(:sort))

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
