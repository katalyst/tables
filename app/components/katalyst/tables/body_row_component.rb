# frozen_string_literal: true

module Katalyst
  module Tables
    class BodyRowComponent < ViewComponent::Base # :nodoc:
      include Katalyst::HtmlAttributes

      renders_many :cells, ->(cell) { cell }

      def before_render
        content # ensure content is rendered so html_attributes can be set
      end

      def header?
        false
      end

      def body?
        true
      end

      def inspect
        "#<#{self.class.name}>"
      end
    end
  end
end
