# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query # :nodoc:
        extend ActiveSupport::Concern

        include Filtering

        class_methods do
          def search_attribute
            _default_attributes.each_value do |attribute|
              return attribute.name if attribute.type.type == :search
            end

            nil
          end
        end

        included do
          attribute :q, :query, default: ""
          alias_attribute :query, :q

          # Note: this is defined inline so that we can overwrite query=
          def q=(value)
            query = super

            Parser.new(self).parse(query)

            query
          end
        end

        using Type::Helpers::Extensions

        def examples_for(key)
          values_method = "#{key.parameterize.underscore}_values"
          if respond_to?(values_method)
            public_send(values_method)
          elsif @attributes.key?(key)
            @attributes[key].type.examples_for(items, @attributes[key])
          end
        end
      end
    end
  end
end
