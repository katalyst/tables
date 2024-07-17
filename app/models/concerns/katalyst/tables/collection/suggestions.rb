# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Suggestions # :nodoc:
        extend ActiveSupport::Concern

        included do
          attribute :p, :integer, filter: false
          alias_attribute :position, :p
        end

        using Type::Helpers::Extensions

        def suggestions(position: self.position)
          query_token = token_at_position(position:)

          attribute = attribute_for_token(query_token:)
          method    = suggestions_method(attribute) if attribute.present?

          # build a suggestions list
          suggestions = if method && respond_to?(method)
                          user_suggestions(attribute:, method:)
                        elsif attribute
                          value_suggestions(attribute:)
                        else
                          attribute_suggestions(query_token:)
                        end

          add_context_suggestions(suggestions:, query_token:, attribute:) if query_token

          suggestions
        end

        private

        def attribute_for_token(query_token:)
          return unless query_token&.tagged?

          attribute = suggestable_attributes[query_token.key]

          return unless attribute

          # construct an attribute from the input token, so we can focus on what the user is currently typing instead
          # of searching for the whole input for this attribute (e.g. if we're constructing an array filter)
          ActiveModel::Attribute.from_user(attribute.name, query_token.value_at(position),
                                           attribute.type, attribute)
        end

        # Augments suggestions to ensure the user always has some feedback on their input.
        def add_context_suggestions(suggestions:, query_token:, attribute:)
          if query_token.tagged?
            if !attribute
              # user has entered a `:` but we don't know the attribute
              errors.add(:query, :unknown_key, input: query_token.key)
            elsif suggestions.none?
              # the user might know more than us about what values are valid
              suggestions << Tables::Suggestions::SearchValue.new(query_token.value_at(position))
            end
          elsif searchable?
            # user is typing an untagged search term, indicate they can continue
            suggestions << Tables::Suggestions::SearchValue.new(query_token.value)
          else
            errors.add(:query, :no_untagged_search, input: query_token.value)
          end
        end

        def attribute_suggestions(query_token:)
          attributes = suggestable_attributes.values

          if query_token&.literal?
            attributes = attributes.select { |a| a.name.include?(query_token.value) }
          end

          attributes.map { |a| Tables::Suggestions::Attribute.new(a.name) }
        end

        def user_suggestions(attribute:, method:)
          suggestions = public_send(method, attribute)

          raise TypeError, "Suggestions must be an array" unless suggestions.is_a?(Enumerable)

          suggestions.map do |suggestion|
            case suggestion
            when Tables::Suggestions::Base
              suggestion
            else
              Tables::Suggestions::CustomValue.new(suggestion, name: attribute.name, type: attribute.type)
            end
          end
        end

        def value_suggestions(attribute:)
          attribute.type.suggestions(unscoped_items, attribute)
        end

        def suggestions_method(attribute)
          :"#{attribute.name.parameterize.underscore}_suggestions" if attribute.present?
        end

        def suggestable_attributes
          @attributes.keys.filter_map do |name|
            attribute = @attributes[name]

            # skip if the attribute can't generate useful suggestions
            next unless attribute.type.filterable?
            next if attribute.type.type == :search

            [name, attribute]
          end.to_h
        end

        def token_at_position(position: self.position)
          @query_parser&.token_at_position(position:)
        end
      end
    end
  end
end
