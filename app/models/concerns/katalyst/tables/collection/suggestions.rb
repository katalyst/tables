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

        # rubocop:disable Metrics/PerceivedComplexity
        def suggestions(position: self.position)
          input = token_at_position(position:)

          attribute = attribute_at_position(position:)
          method    = suggestions_method(attribute)

          # build a suggestions list
          suggestions = if method && respond_to?(method)
                          user_suggestions(attribute:, method:)
                        elsif attribute
                          value_suggestions(attribute:)
                        elsif errors.where(:query, :unknown_key).none?
                          attribute_suggestions(input:)
                        else
                          []
                        end

          # augment to ensure the user always has some feedback on their input
          if input.blank?
            # nothing to add
          elsif searchable? && errors.none? && !attribute
            # user might be typing an untagged search term, indicate they can continue
            suggestions << Tables::Suggestions::SearchValue.new(input)
          elsif suggestions.any?
            # nothing for us to add in this situation
          elsif attribute
            # the term they are typing can be searchable even if it's not in the suggestions list
            suggestions << Tables::Suggestions::CustomValue.new(input, name: attribute.name, type: attribute.type)
          else
            errors.add(:query, :no_suggestions, input:)
          end

          suggestions
        end
        # rubocop:enable Metrics/PerceivedComplexity

        private

        def attribute_suggestions(input:)
          attributes = suggestable_attributes

          attributes = attributes.select { |a| a.name.include?(input) } if input.present?

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

            attribute
          end
        end

        def attribute_at_position(position: self.position)
          attribute = suggestable_attributes.detect do |a|
            a.query_range&.cover?(position)
          end

          if attribute
            # construct an attribute from the input token, so we can focus on what the user is currently typing instead
            # of searching for the whole input for this attribute (e.g. if we're constructing an array filter)
            ActiveModel::Attribute.from_user(attribute.name, token_at_position(position:), attribute.type, attribute)
          end
        end

        def token_at_position(position: self.position)
          if position&.in?(0..query.length)
            prefix = query[...position].match(/\w*\z/)
            suffix = query[position..].match(/\A\w*/)
            "#{prefix}#{suffix}"
          else
            ""
          end
        end
      end
    end
  end
end
