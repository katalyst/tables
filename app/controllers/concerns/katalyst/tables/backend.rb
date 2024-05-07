# frozen_string_literal: true

module Katalyst
  module Tables
    # Configuration for controllers to specify which TableComponent should be used in associated views.
    module Backend
      extend ActiveSupport::Concern

      included do
        class_attribute :_default_table_component, instance_accessor: false
      end

      class_methods do
        # Set the table component to be used as the default for all tables
        # in the views rendered by this controller and its subclasses.
        #
        # @param component [Class] the table component class to use
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
