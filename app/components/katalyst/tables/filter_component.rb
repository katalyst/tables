# frozen_string_literal: true

module Katalyst
  module Tables
    # A component for rendering a data driven filter for a collection.
    #   <%= Katalyst::Tables::FilterComponent.new(collection: @people, url: peoples_path) %>
    #
    # By default, the component will render a form containing a single text field. Interacting with the
    # text field will display a dropdown outlining all available keys and values to be filtered on.
    #
    # You can override how the form and input displays by passing in content to the component.
    # The component provides a helper function `form`
    # to ensure the correct attributes and default form fields are collected.
    # You can pass additional options to the `form` method to modify it.
    #
    #   <%= Katalyst::Tables::FilterComponent.new(collection: @people, url: peoples_path) do |filter| %>
    #     <%= filter.form(builder: GOVUKFormBuilder) do |form| %>
    #         <%= form.govuk_text_field :query %>
    #         <%= form.govuk_submit "Apply" %>
    #     <% end %>
    #   <% end %>
    #
    #
    # Additionally the component allows for access to the dropdown that displays when interacting with the input.
    # The dropdown supports additional "footer" content to be added.
    #
    #   <%= Katalyst::Tables::FilterComponent.new(collection: @people, url: peoples_path) do |filter| %>
    #     <% filter.with_modal(collection:) do |modal| %>
    #         <% modal.with_footer do %>
    #           <%= link_to "Docs", docs_path %>
    #         <% end %>
    #     <% end %>
    #   <% end %>
    #
    class FilterComponent < ViewComponent::Base
      include Katalyst::HtmlAttributes
      include Katalyst::Tables::Frontend

      renders_one :modal, Katalyst::Tables::Filter::ModalComponent

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
                  **options) do |form|
          concat(form.hidden_field(:sort))

          yield form if block_given?
        end
      end

      private

      def default_html_attributes
        {
          data: {
            controller: "tables--filter--modal",
            action:     <<~ACTIONS.gsub(/\s+/, " "),
              click@window->tables--filter--modal#close
              click->tables--filter--modal#open:stop
              keydown.esc->tables--filter--modal#close
            ACTIONS
          },
        }
      end

      def default_input_attributes
        {
          data: {
            action: "focus->tables--filter--modal#open",
          },
        }
      end
    end
  end
end
