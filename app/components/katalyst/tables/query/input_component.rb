# frozen_string_literal: true

module Katalyst
  module Tables
    module Query
      class InputComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes

        attr_reader :form

        def initialize(form:, **)
          super(**)

          @form = form
        end

        def name
          query_attribute || raise(ArgumentError, "No query attribute. " \
                                                  "Does your collection include Katalyst::Tables::Collection::Query?")
        end

        def collection
          form.object
        end

        def default_html_attributes
          {
            data: {
              action:                     %w[
                input->tables--query-input#update
                keyup.enter->tables--query#closeModal
              ],
              tables__query_input_target: "input",
            },
          }
        end

        private

        def placeholder
          t("katalyst.tables.query.placeholder", name: collection.model_name.human.pluralize.downcase)
        end

        def query_attribute
          collection.class.attribute_types.detect { |_, a| a.type == :query }&.first
        end
      end
    end
  end
end
