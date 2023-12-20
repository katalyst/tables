# frozen_string_literal: true

module Katalyst
  module Tables
    # Utilities for controllers that are generating collections for visualisation
    # in a table view using Katalyst::Tables::Frontend.
    module Backend
      extend ActiveSupport::Concern

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
