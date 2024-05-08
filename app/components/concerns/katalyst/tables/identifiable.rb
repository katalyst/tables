# frozen_string_literal: true

module Katalyst
  module Tables
    # Adds dom ids to the table and row components.
    # See [documentation](/docs/identifiable.md) for more details.
    module Identifiable
      extend ActiveSupport::Concern

      module Defaults
        extend self

        # Returns the default dom id for the table, uses the collection's
        # model name's route_key as a sensible default.
        def default_table_id(collection = self.collection)
          collection.model_name.route_key
        end
      end

      included do
        include Defaults
      end

      def initialize(generate_ids: false, **)
        super(**)

        @generate_ids = generate_ids
      end

      def identifiable?
        @generate_ids
      end

      def id
        html_attributes[:id]
      end

      def before_render
        if identifiable?
          update_html_attributes(id: default_table_id(collection)) if id.nil?

          @body_row_callbacks << Proc.new do |row, record|
            row.update_html_attributes(id: dom_id(record))
          end
        end

        super
      end
    end
  end
end
