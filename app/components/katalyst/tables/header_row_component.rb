# frozen_string_literal: true

module Katalyst
  module Tables
    class HeaderRowComponent < ViewComponent::Base # :nodoc:
      include Katalyst::HtmlAttributes

      renders_many :cells, ->(cell) { cell }

      def before_render
        content # ensure content is rendered so html_attributes can be set
      end

      def header?
        true
      end

      def body?
        false
      end

      def inspect
        "#<#{self.class.name}>"
      end
    end
  end
end
