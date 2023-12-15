# frozen_string_literal: true

module Katalyst
  module Turbo
    # Renders a table that uses turbo stream replacement when sorting or
    # paginating.
    class TableComponent < ::Katalyst::TableComponent
      include Tables::TurboReplaceable

      attr_reader :id

      def initialize(collection:, id:, header: true, **options)
        header = if header.is_a?(Hash)
                   default_header_options.merge(header)
                 elsif header
                   default_header_options
                 end

        @id = id

        super(collection: collection, header: header, id: id, **options)
      end

      private

      def default_html_attributes
        {
          data: {
            controller:                            "tables--turbo--collection",
            tables__turbo__collection_query_value: current_query,
            tables__turbo__collection_sort_value:  collection.sort,
          },
        }
      end

      def current_query
        Rack::Utils.build_nested_query(collection.to_params)
      end

      def default_header_options
        { link: { data: { turbo_stream: "" } } }
      end
    end
  end
end
