# frozen_string_literal: true

module Katalyst
  module Tables
    class RowRenderer < ActionView::PartialRenderer # :nodoc:
      include ObjectRendering

      def initialize(lookup_context, collection:, partial:, **options)
        super(lookup_context, options)

        @collection = collection
        @partial    = partial
      end

      def render_row(row, object, view_context)
        @row    = row
        @object = object

        if @partial.blank?
          example  = example_for(@collection)
          @partial = partial_path(example, view_context) if example.present?
        end

        # if we still cannot find an example return an empty table (no header row)
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
        # if none of the above strategies match, return nil
      rescue ArgumentError
        nil # if we could not construct an example without passing arguments, return nil
      end

      def template_keys(path)
        super + [@local_name, :row]
      end

      def render_partial_template(view, locals, template, layout, block)
        locals[@local_name || template.variable] = @object
        locals[:row]                             = @row
        super
      end
    end
  end
end
