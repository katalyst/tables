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

      class RowRenderer < ActionView::PartialRenderer # :nodoc:
        include ObjectRendering

        def initialize(lookup_context, collection:, partial:, **options)
          super(lookup_context, options)

          @collection   = collection
          @partial      = partial
        end

        def render_row(row, object, view_context)
          @row    = row
          @object = object

          if @partial.blank?
            example = example_for(@collection)
            @partial = partial_path(example, view_context) if example.present?
          end

          return "" if @partial.blank?

          @local_name ||= local_variable(@partial)
          render(@partial, view_context, nil)
        end

        private

        def example_for(collection)
          if collection.respond_to?(:items)
            example_for(collection.items)
          elsif collection.respond_to?(:any?) && collection.any?
            collection.first
          elsif collection.respond_to?(:model)
            collection.model.new
          end
        rescue ArgumentError
          nil
        end

        def template_keys(path)
          super + [@local_name, :row]
        end

        def render_partial_template(view, locals, template, layout, block)
          locals[@local_name || template.variable] = @object
          locals[:row]                             = @row
          super(view, locals, template, layout, block)
        end
      end
    end
  end
end
