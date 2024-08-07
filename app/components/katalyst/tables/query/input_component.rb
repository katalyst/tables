# frozen_string_literal: true

module Katalyst
  module Tables
    module Query
      class InputComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes

        attr_reader :form

        define_html_attribute_methods :input_attributes

        def initialize(form:, input: {}, **)
          super(**)

          @form = form

          update_input_attributes(**input)
        end

        def name
          query_attribute || raise(ArgumentError, "No query attribute. " \
                                                  "Does your collection include Katalyst::Tables::Collection::Query?")
        end

        def collection
          form.object
        end

        private

        def default_html_attributes
          {
            class: "query-input",
            data:  {
              controller:      "tables--query-input",
              turbo_permanent: "",
            },
          }
        end

        def default_input_attributes
          {
            spellcheck: false,
            data:       {
              action:                     %w[
                replaceToken->tables--query-input#replaceToken
                tables--query-input#update
                keydown.enter->tables--query#selectActiveSuggestion:prevent
                keydown.esc->tables--query#clear:prevent
                keydown.up->tables--query#moveToPreviousSuggestion:prevent
                keydown.down->tables--query#moveToNextSuggestion:prevent
                keydown.alt+up->tables--query#clearActiveSuggestion:prevent
              ],
              tables__query_input_target: "input",
            },
          }
        end

        def placeholder
          t(".placeholder", name: collection.model_name.human.pluralize.downcase)
        end

        def query_attribute
          collection.class.attribute_types.detect { |_, a| a.type == :query }&.first
        end
      end
    end
  end
end
