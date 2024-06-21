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
            },
          }
        end

        using Collection::Type::Helpers::Extensions

        def attributes
          collection.class.attribute_types
            .select { |_, a| a.filterable? && a.type != :search }
        end

        def values_for(key, attribute)
          values_method = "#{key.parameterize.underscore}_values"
          if collection.respond_to?(values_method)
            return scope_values(attribute, values_method)
          end

          case attribute.type
          when :boolean
            render_options(true, false)
          when :date
            date_values
          when :integer
            integer_values(attribute)
          when :float
            float_values(attribute)
          when :enum
            enum_values(key)
          when :string
            string_values(attribute)
          end
        end

        def scope_values(attribute, values_method)
          values = collection.public_send(values_method)
          attribute.multiple? ? render_array(*values) : render_options(*values)
        end

        def date_values
          render_options("YYYY-MM-DD", ">YYYY-MM-DD", "<YYYY-MM-DD", "YYYY-MM-DD..YYYY-MM-DD")
        end

        def string_values(attribute)
          options = render_options("example", '"an example"')
          safe_join([options, attribute.exact? ? "(exact match)" : "(fuzzy match)"], " ")
        end

        def enum_values(key)
          enums = collection.model.defined_enums

          render_array(*enums[key].keys) if enums.has_key?(key)
        end

        def float_values(attribute)
          if attribute.multiple?
            render_array("0.5", "1", "...")
          else
            render_options("0.5", ">0.5", "<0.5", "-0.5..0.5")
          end
        end

        def integer_values(attribute)
          if attribute.multiple?
            render_array("0", "1", "...")
          else
            render_options("10", ">10", "<10", "0..10")
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
