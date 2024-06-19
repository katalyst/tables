# frozen_string_literal: true

module Katalyst
  module Tables
    module Filter
      class ModalComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes
        include Katalyst::Tables::Frontend

        DEFAULT_ATTRIBUTES = %w[page sort search query].freeze

        renders_one :footer

        attr_reader :collection, :url

        def initialize(collection:, **)
          super(**)

          @collection = collection
        end

        private

        def default_html_attributes
          {
            class: "filter-keys-modal",
            data:  {
              tables__filter__modal_target: "modal",
            },
          }
        end

        def attributes
          collection.class.attribute_types.except(*DEFAULT_ATTRIBUTES)
        end

        def values_for(key, attribute)
          values_method = "#{key.parameterize.underscore}_values"
          if attribute.type == :boolean
            render_options(true, false)
          elsif attribute.type == :date_range
            render_options("YYYY-MM-DD", ">YYYY-MM-DD", "<YYYY-MM-DD", "YYYY-MM-DD..YYYY-MM-DD")
          elsif collection.model.defined_enums.has_key?(key)
            render_array(*collection.model.defined_enums[key].keys)
          elsif collection.respond_to?(values_method)
            if collection.class.enum_attribute?(key)
              render_array(*collection.public_send(values_method))
            else
              render_options(*collection.public_send(values_method))
            end
          end
        end

        def render_option(value)
          tag.code(value.to_s)
        end

        def render_options(*values)
          safe_join(values.map { |value| render_option(value) }, ", ")
        end

        def render_array(*values)
          safe_join(["[", render_options(*values), "]"])
        end
      end
    end
  end
end
