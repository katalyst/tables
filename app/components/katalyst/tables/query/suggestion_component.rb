# frozen_string_literal: true

module Katalyst
  module Tables
    module Query
      class SuggestionComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes

        delegate :type, :value, to: :@suggestion

        def initialize(suggestion:, index:, **)
          super(**)

          @suggestion = suggestion
          @index      = index
        end

        def dom_id
          "suggestion_#{@index}"
        end

        def default_html_attributes
          {
            id:    dom_id,
            class: ["suggestion", type.to_s],
            role:  "option",
            data:  {
              action:                    %w[
                click->tables--query#selectSuggestion
                query:select->tables--query#selectSuggestion
              ],
              tables__query_value_param: value_param,
            },
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

        def value_param
          return "#{@suggestion.value}:" if @suggestion.type == :attribute

          @suggestion.value
        end
      end
    end
  end
end
