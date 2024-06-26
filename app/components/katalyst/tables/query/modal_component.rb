# frozen_string_literal: true

module Katalyst
  module Tables
    module Query
      class ModalComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes
        include Katalyst::Tables::Frontend

        renders_one :footer

        attr_reader :collection, :url

        def initialize(collection:, **)
          super(**)

          @collection = collection
        end

        private

        def default_html_attributes
          {
            class: "query-modal",
            data:  {
              tables__query_target: "modal",
              action:               ["turbo:before-morph-attribute->tables--query#beforeMorphAttribute"],
            },
          }
        end

        using Collection::Type::Helpers::Extensions

        def show_values?
          current_key && attributes[current_key]
        end

        def current_key
          if instance_variable_defined?(:@current_key)
            @current_key
          else
            match = /(?<key>[\w\.]+):\s?\z/.match(collection.query.to_s)
            @current_key = (match[:key] if match)
          end
        end

        def attributes
          collection.class.attribute_types
            .select { |_, a| a.filterable? && a.type != :search }
            .to_h
        end

        def values_for(key)
          collection.examples_for(key)
        end
      end
    end
  end
end
