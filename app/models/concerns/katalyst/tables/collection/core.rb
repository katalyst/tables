# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Core # :nodoc:
        extend ActiveSupport::Concern

        include ActiveModel::Model
        include ActiveModel::Attributes
        include ActiveModel::Dirty
        include ActiveSupport::Configurable

        included do
          class_attribute :reducers, default: ActionDispatch::MiddlewareStack.new

          class << self
            delegate :use, :before, to: :reducers
          end

          attr_accessor :items

          delegate :model, :to_model, :each, :count, :empty?, to: :items, allow_nil: true
          delegate :model_name, to: :model, allow_nil: true
        end

        def initialize(**options)
          super

          clear_changes_information
        end

        def filter
          # no-op by default
        end

        def filtered?
          !self.class.new.filters.eql?(filters)
        end

        def filters
          attributes.except("page", "sort")
        end

        def apply(items)
          @items = items
          reducers.build do |_|
            filter
            self
          end.call(self)
          self
        end

        def with_params(params)
          self.attributes = params.permit(self.class.attribute_types.keys)

          self
        end

        # Returns a hash of the current attributes that have changed from defaults.
        def to_params
          attributes.slice(*changed)
        end

        def inspect
          "#<#{self.class.name} @attributes=#{attributes.inspect} @model=\"#{model}\" @count=#{items&.count}>"
        end
      end
    end
  end
end
