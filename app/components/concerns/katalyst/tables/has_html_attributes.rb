# frozen_string_literal: true

require "html_attributes_utils"

module Katalyst
  module Tables
    module HasHtmlAttributes # :nodoc:
      extend ActiveSupport::Concern

      using HTMLAttributesUtils

      DEFAULT_MERGEABLE_ATTRIBUTES = [
        *HTMLAttributesUtils::DEFAULT_MERGEABLE_ATTRIBUTES,
        %i[data controller],
        %i[data action]
      ].freeze

      def initialize(**options)
        super(**options.except(:id, :aria, :class, :data, :html))

        self.html_attributes = options
      end

      # Add HTML options to the current component.
      # Public method for customizing components from within
      def html_attributes=(options)
        @html_attributes = options.slice(:id, :aria, :class, :data).merge(options.fetch(:html, {}))
      end

      # Backwards compatibility with tables 1.0
      alias options html_attributes=

      private

      def html_attributes
        default_attributes
          .deep_merge_html_attributes(@html_attributes, mergeable_attributes: DEFAULT_MERGEABLE_ATTRIBUTES)
      end

      def default_attributes
        {}
      end
    end
  end
end
