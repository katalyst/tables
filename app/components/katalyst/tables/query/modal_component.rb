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

        def show_examples?
          current_key && attributes[current_key]
        end

        def current_key
          unless instance_variable_defined?(:@current_key)
            attributes.each_key do |key|
              @current_key = key if collection.query_active?(key)
            end
          end

          @current_key ||= nil
        end

        def attributes
          collection.class.attribute_types
            .select { |_, a| a.filterable? && a.type != :search }
            .to_h
        end

        def available_filters
          keys = attributes.keys

          if current_token.present?
            keys = keys.select { |k| k.include?(current_token) }
          end

          keys.map do |key|
            [key, collection.model.human_attribute_name(key)]
          end
        end

        def examples_for(key)
          collection.examples_for(key)&.map(&:to_s)&.compact_blank || []
        end

        def format_value(value)
          if /\A[\w.-]*\z/.match?(value)
            value
          else
            %("#{value}")
          end
        end

        def current_token
          return nil unless collection.position&.in?(0..collection.query.length)

          prefix = collection.query[...collection.position].match(/\w*\z/)
          suffix = collection.query[collection.position..].match(/\A\w*/)

          "#{prefix}#{suffix}"
        end
      end
    end
  end
end
