# frozen_string_literal: true

module Examples
  class SearchCollection < Katalyst::Tables::Collection::Base
    attribute :search, :string

    def filter
      self.items = items.search(search) if search.present?
    end
  end

  class TagsCollection < Katalyst::Tables::Collection::Base
    attribute :tags, default: []

    def filter
      self.items = items.with_tags(tags) if tags.any?
    end
  end

  class CustomParamsCollection < Katalyst::Tables::Collection::Base
    attr_accessor :custom

    def self.permitted_params
      super + ["custom"]
    end

    def filter
      self.items = items.with_custom(custom) if custom.present?
    end
  end

  class NestedCollection < Katalyst::Tables::Collection::Base
    class Nested
      include ActiveModel::Model
      include ActiveModel::Attributes

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
      nested.attributes = attributes
    end

    def self.permitted_params
      super + [nested: Nested.attribute_names]
    end

    def filter
      self.items = items.filter_by(nested) unless nested.attributes.empty?
    end
  end
end
