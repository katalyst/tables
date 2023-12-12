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
      # @return [[SortForm, ActiveRecord::Relation]]
      def table_sort(collection)
        column, direction = params[:sort]&.split
        direction         = "asc" unless SortForm::DIRECTIONS.include?(direction)

        SortForm.new(column:    column,
                     direction: direction)
          .apply(collection)
      end

      def self_referred?
        request.referer.present? && URI.parse(request.referer).path == request.path
      end
      alias self_refered? self_referred?

      included do
        class_attribute :_default_table_component, instance_accessor: false
      end

      class_methods do
        # Set the table component to be used as the default for all tables
        # in the views rendered by this controller and its subclasses.
        #
        # ==== Parameters
        # * <tt>component</tt> - Default table component, an instance of +Katalyst::TableComponent+
        def default_table_component(component)
          self._default_table_component = component
        end
      end

      # Default table component for this controller
      def default_table_component
        self.class._default_table_component
      end
    end
  end
end
