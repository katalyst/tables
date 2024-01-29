# frozen_string_literal: true

module Katalyst
  module Tables
    module HasTableContent # :nodoc:
      extend ActiveSupport::Concern

      def initialize(object_name: nil, partial: nil, as: nil, **options)
        super(**options)

        @object_name = object_name || model_name&.i18n_key
        @partial     = partial
        @as          = as
      end

      def model_name
        collection.model_name if collection.respond_to?(:model_name)
      end

      private

      def row_proc
        if @row_proc
          @row_proc
        elsif @__vc_render_in_block
          @row_proc = @__vc_render_in_block
        else
          @row_proc = Proc.new do |row, object|
            row_renderer.render_row(row, object, view_context)
          end
        end
      end

      def row_renderer
        @row_renderer ||= RowRenderer.new(@lookup_context,
                                          collection: collection,
                                          as:         @as,
                                          partial:    @partial,
                                          variants:   [:row],
                                          formats:    [:html])
      end
    end
  end
end
