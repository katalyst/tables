# frozen_string_literal: true

module Katalyst
  module Tables
    class PagyNavComponent < ViewComponent::Base # :nodoc:
      include Pagy::Frontend

      attr_reader :pagy_options

      def initialize(collection: nil, pagy: nil, **pagy_options)
        super()

        pagy ||= collection&.pagination if collection.respond_to?(:pagination)

        raise ArgumentError, "pagy is required" if pagy.blank?

        @pagy         = pagy
        @pagy_options = pagy_options
      end

      def call
        pagy_nav(@pagy, **pagy_options).html_safe # rubocop:disable Rails/OutputSafety
      end
    end
  end
end
