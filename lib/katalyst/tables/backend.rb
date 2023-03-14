# frozen_string_literal: true

require "active_support"
require "active_support/concern"

require_relative "backend/sort_form"

module Katalyst
  module Tables
    # Utilities for controllers that are generating collections for visualisation
    # in a table view using Katalyst::Tables::Frontend.
    #
    # Provides `table_sort` for sorting based on column interactions (sort param).
    module Backend
      extend ActiveSupport::Concern

      # Sort the given collection by params[:sort], which is set when a user
      # interacts with a column header in a frontend table view.
      #
      # @param sort [String] Sort ordering. Defaults to params[:sort]
      # @return [[SortForm, ActiveRecord::Relation]]
      def table_sort(collection, sort = params[:sort])
        column, direction = sort&.split(" ")
        direction         = "asc" unless SortForm::DIRECTIONS.include?(direction)

        SortForm.new(self,
                     column: column,
                     direction: direction)
                .apply(collection)
      end

      included do
        class_attribute :_default_table_builder, instance_accessor: false
      end

      class_methods do
        # Set the table builder to be used as the default for all tables
        # in the views rendered by this controller and its subclasses.
        #
        # ==== Parameters
        # * <tt>builder</tt> - Default table builder, an instance of +Katalyst::Tables::Frontend::TableBuilder+
        def default_table_builder(builder)
          self._default_table_builder = builder
        end
      end

      # Default table builder for the controller
      def default_table_builder
        self.class._default_table_builder
      end
    end
  end
end
