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

        DIRECTIONS = %w[asc desc].freeze

        module SortParams
          refine Hash do
            def to_param
              "#{self[:column]} #{self[:direction]}"
            end
          end

          refine String do
            def to_param
              to_h.to_param
            end

            def to_h
              column, direction = split(/[ +]/, 2)

              direction = "asc" unless DIRECTIONS.include?(direction)
              { column:, direction: }
            end
          end

          refine Symbol do
            def to_param
              to_s.to_param
            end

            def to_h
              to_s.to_h
            end
          end
        end

        using SortParams

        included do
          attribute :sort, :string, filter: false

          attr_reader :default_sort
        end

        def initialize(sorting: config.sorting, **)
          @default_sort = sorting.to_param if sorting.present?

          super(sort: @default_sort, **) # set default sort based on config
        end

        def default_sort?
          sort == @default_sort
        end

        # Returns true if the collection supports sorting on the given column.
        # A column supports sorting if it is a database column or if
        # the collection responds to `order_by_#{column}(direction)`.
        #
        # @param column [String, Symbol]
        # @return [true, false]
        def sortable?(column = nil)
          if column.nil?
            @default_sort.present?
          else
            items.respond_to?(:"order_by_#{column}") || items.model.has_attribute?(column.to_s)
          end
        end

        # Set the current sort behaviour of the collection.
        #
        # @param value [String, Hash] "column direction", or { column:, direction: }
        def sort=(value)
          super(value.to_param) if @default_sort
        end

        # Returns the current sort behaviour of the given column, for use as a
        # column heading class in the table view.
        #
        # @param column [String, Symbol] the table column as defined in table_with
        # @return [String] the current sort behaviour of the given column
        def sort_status(column)
          current, direction = sort.to_h.values_at(:column, :direction)
          direction if column.to_s == current
        end

        # Calculates the sort parameter to apply when the given column is toggled.
        #
        # @param column [String, Symbol]
        # @return [String]
        def toggle_sort(column)
          current, direction = sort.to_h.values_at(:column, :direction)

          return "#{column} asc" unless column.to_s == current

          direction == "asc" ? "#{column} desc" : "#{column} asc"
        end

        class Sort # :nodoc:
          include Backend

          def initialize(app)
            @app = app
          end

          using SortParams

          def call(collection)
            collection = @app.call(collection)

            column, direction = collection.sort.to_h.values_at(:column, :direction)

            return collection if column.nil?

            if collection.items.respond_to?(:"order_by_#{column}")
              collection.items = collection.items.reorder(nil).public_send(:"order_by_#{column}", direction.to_sym)
            elsif collection.model.has_attribute?(column)
              collection.items = collection.items.reorder(column => direction)
            end

            collection
          end
        end
      end
    end
  end
end
