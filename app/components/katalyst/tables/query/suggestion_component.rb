# frozen_string_literal: true

module Katalyst
  module Tables
    module Query
      class SuggestionComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes

        delegate :type, :value, to: :@suggestion

        def initialize(suggestion:, **)
          super(**)

          @suggestion = suggestion
        end

        def default_html_attributes
          {
            class: ["suggestion", type.to_s],
          }
        end

        private

        def format_value(value)
          if /\A[\w.-]*\z/.match?(value.to_s)
            value.to_s
          else
            %("#{value}")
          end
        end
      end
    end
  end
end
