# frozen_string_literal: true

module Katalyst
  module Tables
    class PagyNavComponent < ViewComponent::Base # :nodoc:
      # Pagy is not a required gem unless you're using pagination
      # Expect to see NoMethodError failures if pagy is not available
      "Pagy::Frontend".safe_constantize&.tap { |pagy| include(pagy) }

      def self.pagy_legacy?
        Pagy::VERSION.scan(/\d+/).first.to_i <= 8
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
        pagy_nav(@pagy, **pagy_options).html_safe # rubocop:disable Rails/OutputSafety
      end

      def pagy_options
        default_pagy_options.merge(@pagy_options)
      end

      def inspect
        "#<#{self.class.name} pagy: #{@pagy.inspect}>"
      end

      private

      def default_pagy_options
        pagy_legacy? ? {} : { anchor_string: 'data-turbo-action="replace"' }
      end
    end
  end
end
