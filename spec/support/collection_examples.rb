# frozen_string_literal: true

module Examples
  # Example of a collection that uses a simple attribute for a filter.
  class SearchCollection < Katalyst::Tables::Collection::Base
    attribute :search, :string, default: ""

    def filter
      self.items = items.search(search) if search.present?
    end
  end

  # Example of a collection that uses an array value for an attribute.
  class TagsCollection < Katalyst::Tables::Collection::Base
    attribute :tags, :enum

    def filter
      self.items = items.with_tags(tags) if tags.any?
    end
  end

  # Example of a collection where attributes are not used, showing that entirely
  # custom extensions are possible.
  class CustomParamsCollection < Katalyst::Tables::Collection::Base
    attr_accessor :custom

    def self.permitted_params
      super + ["custom"]
    end

    def filtered?
      super || custom.present?
    end

    def filter
      self.items = items.with_custom(custom) if custom.present?
    end

    def to_params
      custom.present? ? super.merge("custom" => custom) : super
    end
  end

  # Example of a collection that uses a custom nested type for filtering.
  class NestedCollection < Katalyst::Tables::Collection::Base
    class Nested
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Dirty

      attribute :custom, default: ""

      def hash
        attributes.hash
      end

      def eql?(other)
        other.respond_to?(:attributes) && attributes == other.attributes
      end
      alias == eql?
    end

    attribute :nested, default: -> { Nested.new }

    def nested=(attributes)
      super(Nested.new(attributes))
    end

    def self.permitted_params
      super + [nested: Nested.attribute_names]
    end

    def filter
      self.items = items.filter_by(nested) if nested.changed?
    end
  end

  # Example of a collection that uses a simple attribute for a filter.
  class FilterCollection < Katalyst::Tables::Collection::Filter
    attribute :search, :string, default: ""

    def filter
      self.items = items.search(search) if search.present?
    end
  end
end
