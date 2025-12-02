# frozen_string_literal: true

module Katalyst
  module Tables
    class PagyNavComponent < ViewComponent::Base # :nodoc:
      # Pagy is not a required gem unless you're using pagination
      # Expect to see NoMethodError failures if pagy is not available
      "Pagy::Frontend".safe_constantize&.tap { |pagy| include(pagy) }

      def self.pagy_legacy?
        pagy_major < 43
      end

      def self.pagy_pre_8?
        pagy_major < 8
      end

      def self.pagy_major
        @pagy_major ||= Pagy::VERSION.scan(/\d+/).first.to_i
      end

      delegate :pagy_legacy?, to: :class

      def initialize(collection: nil, pagy: nil, **pagy_options)
        super()

        pagy ||= collection&.pagination if collection.respond_to?(:pagination)

        raise ArgumentError, "pagy is required" if pagy.blank?

        @pagy         = pagy
        @pagy_options = pagy_options
      end

      def call
        render_nav.html_safe # rubocop:disable Rails/OutputSafety
      end

      def pagy_options
        default_pagy_options.merge(@pagy_options)
      end

      def inspect
        "#<#{self.class.name} pagy: #{@pagy.inspect}>"
      end

      private

      def render_nav
        return pagy_nav(@pagy, **pagy_options) if pagy_legacy?

        @pagy.series_nav(**pagy_options)
      end

      def default_pagy_options
        pagy_legacy? ? {} : { anchor_string: 'data-turbo-action="replace"' }
      end
    end
  end
end
