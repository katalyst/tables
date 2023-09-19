# frozen_string_literal: true

require "html_attributes_utils"

module Katalyst
  module Tables
    # Adds HTML attributes to a component.
    # Accepts HTML attributes from the constructor or via `html_attributes=`.
    # These are merged with the default attributes defined in the component.
    # Adds support for custom html attributes for other tags, e.g.:
    #   define_html_attribute_methods :table_attributes, default: {}
    #   tag.table(**table_attributes)
    module HasHtmlAttributes
      extend ActiveSupport::Concern

      using HTMLAttributesUtils

      MERGEABLE_ATTRIBUTES = [
        *HTMLAttributesUtils::DEFAULT_MERGEABLE_ATTRIBUTES,
        %i[data controller],
        %i[data action]
      ].freeze

      refine Hash do
        def merge_html(attributes)
          deep_merge_html_attributes(attributes, mergeable_attributes: MERGEABLE_ATTRIBUTES)
        end
      end

      class_methods do
        using HasHtmlAttributes

        def define_html_attribute_methods(name, default: {})
          define_method("default_#{name}") { default }
          private("default_#{name}")

          define_method(name) do
            send("default_#{name}").merge_html(instance_variable_get("@#{name}") || {})
          end

          define_method("#{name}=") do |options|
            instance_variable_set("@#{name}", options.slice(:id, :aria, :class, :data).merge(options.fetch(:html, {})))
          end
        end
      end

      included do
        define_html_attribute_methods :html_attributes, default: {}

        # Backwards compatibility with tables 1.0
        alias_method :options, :html_attributes=
      end

      def initialize(**options)
        super(**options.except(:id, :aria, :class, :data, :html))

        self.html_attributes = options
      end
    end
  end
end
