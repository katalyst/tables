# frozen_string_literal: true

module Katalyst
  module Tables
    # A component for rendering a data driven filter for a collection.
    #   <%= table_query_with(collection:) %>
    # Equivalent to:
    #   <%= render Katalyst::Tables::QueryComponent.new(collection: @people, url: peoples_path) %>
    #
    # By default, the component will render a form containing a single text field. Interacting with the
    # text field will display a dropdown outlining all available keys and values to be filtered on.
    #
    # You can override how the form and input displays by passing in content to the component.
    # The component provides a helper function `form`
    # to ensure the correct attributes and default form fields are collected.
    # You can pass additional options to the `form` method to modify it.
    #
    # Caution: `config.view_component.capture_compatibility_patch_enabled = true` is required for this to work.
    #
    #   <%= table_query_with(collection:) do |component| %>
    #     <% component.with_form(builder: GOVUKFormBuilder) do |form| %>
    #       <%= render component.query_input(form:) %>
    #       <%= form.govuk_submit "Apply" %>
    #     <% end %>
    #   <% end %>
    #
    # Additionally the component allows for access to the dropdown that displays when interacting with the input.
    # The dropdown supports additional "footer" content to be added.
    #
    #   <%= table_query_with(collection:) do |component| %>
    #     <% component.with_modal(collection:) do |modal| %>
    #       <% modal.with_footer do %>
    #         <%= link_to "Docs", docs_path %>
    #       <% end %>
    #     <% end %>
    #   <% end %>
    class QueryComponent < ViewComponent::Base
      include Katalyst::HtmlAttributes
      include Katalyst::Tables::Frontend

      renders_one :query_input, Katalyst::Tables::Query::InputComponent
      renders_one :modal, Katalyst::Tables::Query::ModalComponent

      attr_reader :collection, :url

      def initialize(collection:, url:, **)
        super(**)

        @collection = collection
        @url        = url

        # defaults, can be overwritten from content
        with_modal(collection:)
        with_form
      end

      def before_render
        content # content is discarded, but may alter slots
      end

      # Override the default form options for query. Proxies all arguments to `form_with`.
      #
      # Caution: requires config.view_component.capture_compatibility_patch_enabled to be set
      def with_form(model: collection, url: @url, method: :get, **options, &block)
        @form_options = { model:, url:, method:, **options }
        @form_block = block
      end

      def with_modal(collection: self.collection, **, &)
        set_slot(:modal, nil, collection:, **, &)
      end

      def sort_input(form:)
        return if collection.default_sort?

        form.hidden_field(:sort)
      end

      private

      def default_html_attributes
        {
          class: "katalyst--tables--query",
          data:  {
            controller:   "tables--query",
            turbo_action: :replace,
            action:       %w[
              click@window->tables--query#closeModal
              click->tables--query#openModal:stop
              focusin@window->tables--query#closeModal
              focusin->tables--query#openModal:stop
              submit->tables--query#submit
              input->tables--query#update
              keydown.tab->tables--query#selectFirstSuggestion
            ],
          },
        }
      end
    end
  end
end
