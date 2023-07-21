# frozen_string_literal: true

module Katalyst
  module Turbo
    # Renders a table that uses turbo stream replacement when sorting or
    # paginating.
    class TableComponent < ::Katalyst::TableComponent
      include Tables::TurboReplaceable

      def initialize(collection:, id:, header: true, **options)
        header = if header.is_a?(Hash)
                   default_header_options.merge(header)
                 elsif header
                   default_header_options
                 end

        super(collection: collection, header: header, id: id, **options)
      end

      def id
        html_attributes[:id]
      end

      private

      def default_attributes
        {
          data: {
            controller: "tables--turbo-collection",
            tables__turbo_collection_url_value: current_path,
            tables__turbo_collection_sort_value: collection.sort
          }
        }
      end

      def current_path
        params = collection.to_params
        query_string = params.empty? ? "" : "?#{Rack::Utils.build_nested_query(params)}"

        "#{request.path}#{query_string}"
      end

      def default_header_options
        { link: { data: { turbo_stream: "" } } }
      end
    end
  end
end
