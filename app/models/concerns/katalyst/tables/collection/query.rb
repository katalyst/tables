# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Query # :nodoc:
        extend ActiveSupport::Concern

        include Filtering
        include Suggestions

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
        end

        def searchable?
          self.class.search_attribute.present?
        end

        using Type::Helpers::Extensions

        private

        def _assign_attributes(new_attributes)
          result = super

          if query_changed?
            @query_parser = Parser.new(self).parse(query)

            @query_parser.tagged.each do |k, p|
              next unless @attributes.key?(k)

              _assign_attribute(k, p.value)
            end

            if @query_parser.untagged.any? && (search = self.class.search_attribute)
              _assign_attribute(search, @query_parser.untagged.map(&:value).join(" "))
            end
          end

          result
        end
      end
    end
  end
end
