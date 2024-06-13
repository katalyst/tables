# frozen_string_literal: true

module Katalyst
  module Tables
    module HasTableContent # :nodoc:
      extend ActiveSupport::Concern

      def initialize(object_name: nil, partial: nil, as: nil, **)
        super(**)

        @object_name = object_name || model_name&.i18n_key
        @partial     = partial
        @as          = as
      end

      def before_render
        # move @__vc_render_in_block to @row_proc to avoid slot lookup attempting to call it
        @row_proc = @__vc_render_in_block
        @__vc_render_in_block = nil
      end

      def model_name
        collection.model_name if collection.respond_to?(:model_name)
      end

      private

      def row_content(row, record)
        @current_row = row
        @current_record = record
        row_proc.call(self, record)
      ensure
        @current_row = nil
        @current_record = nil
      end

      def row_proc
        @row_proc ||= Proc.new do |table, object|
          row_renderer.render_row(table, object, view_context)
        end
      end

      def row_renderer
        @row_renderer ||= RowRenderer.new(@lookup_context,
                                          collection:,
                                          as:         @as,
                                          partial:    @partial,
                                          variants:   [:row],
                                          formats:    [:html])
      end
    end
  end
end
