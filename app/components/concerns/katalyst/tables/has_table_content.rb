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
        @row_proc ||= @__vc_render_in_block || method(:row_partial)
      end

      def row_partial(row, record = nil)
        partial = @partial || model_name&.param_key&.to_s
        as      = @as || model_name&.param_key&.to_sym
        render(partial: partial, variants: [:row], locals: { as => record, row: row })
      end
    end
  end
end
