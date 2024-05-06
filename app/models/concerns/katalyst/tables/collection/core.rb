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
        end

        included do
          attr_accessor :items

          delegate :each, :count, :empty?, to: :items, allow_nil: true
        end

        def initialize(**options)
          super

          clear_changes_information
        end

        # Collections that do not include Sorting are never sortable.
        def sortable?
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
      end
    end
  end
end
