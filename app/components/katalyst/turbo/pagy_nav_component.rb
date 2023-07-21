# frozen_string_literal: true

module Katalyst
  module Turbo
    class PagyNavComponent < Tables::PagyNavComponent # :nodoc:
      include Tables::TurboReplaceable

      def initialize(id:, **options)
        super(pagy_id: id, **options)
      end

      def id
        pagy_options[:pagy_id]
      end

      private

      def pagy_options
        super.merge(link_extra: "data-turbo-stream")
      end
    end
  end
end
