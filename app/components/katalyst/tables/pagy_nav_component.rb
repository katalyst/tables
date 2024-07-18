# frozen_string_literal: true

module Katalyst
  module Tables
    class PagyNavComponent < ViewComponent::Base # :nodoc:
      # Pagy is not a required gem unless you're using pagination
      # Expect to see NoMethodError failures if pagy is not available
      "Pagy::Frontend".safe_constantize&.tap { |pagy| include(pagy) }

      attr_reader :pagy_options

      def initialize(collection: nil, pagy: nil, **pagy_options)
        super()

        pagy ||= collection&.pagination if collection.respond_to?(:pagination)

        raise ArgumentError, "pagy is required" if pagy.blank?

        @pagy         = pagy
        @pagy_options = pagy_options
      end

      # rubocop:disable Rails/OutputSafety
      def call
        pagy_nav(@pagy, anchor_string: "data-turbo-action=\"replace\"", **pagy_options).html_safe
      end
      # rubocop:enable Rails/OutputSafety

      def inspect
        "#<#{self.class.name} pagy: #{@pagy.inspect}>"
      end
    end
  end
end
