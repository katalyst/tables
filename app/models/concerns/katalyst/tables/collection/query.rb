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

          attribute :p, :integer, filter: false
          alias_attribute :position, :p
        end

        using Type::Helpers::Extensions

        def examples_for(key)
          key = key.to_s
          examples_method = "#{key.parameterize.underscore}_examples"
          if respond_to?(examples_method)
            public_send(examples_method)
          elsif @attributes.key?(key)
            @attributes[key].type.examples_for(unscoped_items, @attributes[key])
          end
        end

        def query_active?(attribute)
          @attributes[attribute].query_range&.cover?(position)
        end

        private

        def _assign_attributes(new_attributes)
          result = super

          if query_changed?
            parser = Parser.new(self).parse(query)

            parser.tagged.each do |k, p|
              if @attributes.key?(k)
                _assign_attribute(k, p.value)
                @attributes[k].query_range = p.range
              else
                errors.add(k, :unknown)
              end
            end

            if parser.untagged.any? && (search = self.class.search_attribute)
              _assign_attribute(search, parser.untagged.join(" "))
            end
          end

          result
        end
      end
    end
  end
end
