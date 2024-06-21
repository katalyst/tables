# frozen_string_literal: true

module Katalyst
  module Tables
    # A component for rendering a data driven filter for a collection.
    #   <%= Katalyst::Tables::QueryComponent.new(collection: @people, url: peoples_path) %>
    #
    # By default, the component will render a form containing a single text field. Interacting with the
    # text field will display a dropdown outlining all available keys and values to be filtered on.
    #
    # You can override how the form and input displays by passing in content to the component.
    # The component provides a helper function `form`
    # to ensure the correct attributes and default form fields are collected.
    # You can pass additional options to the `form` method to modify it.
    #
    #   <%= Katalyst::Tables::QueryComponent.new(collection: @people, url: peoples_path) do |query| %>
    #     <%= query.form(builder: GOVUKFormBuilder) do |form| %>
    #       <%= form.govuk_text_field :q %>
    #       <%= form.govuk_submit "Apply" %>
    #       <%= modal %>
    #     <% end %>
    #   <% end %>
    #
    # Additionally the component allows for access to the dropdown that displays when interacting with the input.
    # The dropdown supports additional "footer" content to be added.
    #
    #   <%= Katalyst::Tables::QueryComponent.new(collection: @people, url: peoples_path) do |query| %>
    #     <% query.with_modal(collection:) do |modal| %>
    #       <% modal.with_footer do %>
    #         <%= link_to "Docs", docs_path %>
    #       <% end %>
    #     <% end %>
    #   <% end %>
    class QueryComponent < ViewComponent::Base
      include Katalyst::HtmlAttributes
      include Katalyst::Tables::Frontend

      renders_one :modal, Katalyst::Tables::Query::ModalComponent

      define_html_attribute_methods :input_attributes

      attr_reader :collection, :url

      def initialize(collection:, url:, **)
        super(**)

        @collection = collection
        @url        = url
      end

      def before_render
        with_modal(collection:) unless modal?
      end

      def form(url: @url, **options, &)
        form_with(model:  collection,
                  url:,
                  method: :get,
                  **options,
                  **html_attributes) do |form|
          concat(sort_input(form:))

          yield form if block_given?
        end
      end

      def query_input(form:)
        Query::InputComponent.new(form:, **input_attributes)
      end

      def sort_input(form:)
        return if collection.default_sort?

        form.hidden_field(:sort)
      end

      private

      def default_html_attributes
        {
          data: {
            controller: "tables--query",
            action:     %w[
              click@window->tables--query#closeModal
              click->tables--query#openModal:stop
              focusin@window->tables--query#closeModal
              focusin->tables--query#openModal:stop
              keydown.esc->tables--query#clear:stop
              submit->tables--query#submit
            ],
          },
        }
      end
    end
  end
end
