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
      end
    end
  end
end
