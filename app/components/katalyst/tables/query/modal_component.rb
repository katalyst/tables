# frozen_string_literal: true

module Katalyst
  module Tables
    module Query
      class ModalComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes
        include Katalyst::Tables::Frontend

        renders_one :footer
        renders_many :suggestions, SuggestionComponent

        attr_reader :collection, :url

        def initialize(collection:, **)
          super(**)

          @collection = collection
        end

        def before_render
          collection.suggestions.each_with_index do |suggestion, index|
            with_suggestion(suggestion:, index:)
          end
        end

        private

        def default_html_attributes
          {
            id:    "suggestion-dialog",
            class: "query-modal",
            role:  "dialog",
            aria:  {
              label: t(".suggestions_title"),
            },
            data:  {
              tables__query_target: "modal",
              action:               ["turbo:before-morph-attribute->tables--query#beforeMorphAttribute"],
            },
          }
        end
      end
    end
  end
end
