# frozen_string_literal: true

module Katalyst
  module Turbo
    class PagyNavComponent < Tables::PagyNavComponent # :nodoc:
      include Tables::TurboReplaceable

      def initialize(id:, **options)
        super(id:, **options)
      end

      def id
        pagy_options[:id]
      end

      private

      def pagy_options
        super.merge(anchor_string: "data-turbo-stream")
      end
    end
  end
end
