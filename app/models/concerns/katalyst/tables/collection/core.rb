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

        include HasParams
        include Reducers

        class_methods do
          def permitted_params
            _default_attributes.to_h.each_with_object([]) do |(k, v), h|
              h << case v
                   when ::Array
                     { k => [] }
                   else
                     k
                   end
            end
          end

          using Type::Value::Extensions

          def attribute(name, type = nil, default: (no_default = true), **)
            type = type.is_a?(Symbol) ? resolve_type_name(type, **) : type || Type::Value.new

            default = type.default_value if no_default

            default.nil? && no_default ? super(name, type, **) : super
          end

          private

          # @override ActiveModel::AttributeRegistration::ClassMethods#resolve_type_name()
          def resolve_type_name(name, **)
            # note, this is Katalyst::Tables::Collection::Type, not ActiveModel::Type
            Type.lookup(name, **)
          end
        end

        included do
          attr_accessor :items

          delegate :each, :count, :empty?, to: :items, allow_nil: true
        end

        def initialize(**options)
          super

          clear_changes_information
        end

        # Collections are filtered when any parameters have changed from their defaults.
        def filtered?
          filters.any?
        end

        # Collections that do not include Sorting are never sortable.
        def sortable?
          false
        end

        # Collections that do not include Query are never searchable.
        def searchable?
          false
        end

        def apply(items)
          @items = items
          reducers.build do |_|
            filter
            self
          end.call(self)
          self
        end

        def filter
          # no-op by default
        end

        def filters
          changes.except("sort", "page", "query").transform_values(&:second)
        end

        def model
          if items < ActiveRecord::Base
            items
          else
            items.model
          end
        end
      end
    end
  end
end
