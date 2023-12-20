# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module HasParams # :nodoc:
        extend ActiveSupport::Concern

        refine Object do
          def to_params
            as_json
          end
        end

        refine ActiveModel::AttributeSet do
          def to_params
            to_h.transform_values(&:to_params).as_json
          end
        end

        refine ActiveModel::Attributes do
          def to_params
            if respond_to?(:changed)
              @attributes.to_params.slice(*changed)
            else
              @attributes.to_params
            end
          end
        end

        using HasParams

        # Returns a hash of the current attributes that have changed from defaults.
        # This uses Refinements internally so it needs to be exposed publicly with this super call.
        # rubocop:disable Lint/UselessMethodDefinition
        def to_params
          super
        end
        # rubocop:enable Lint/UselessMethodDefinition
      end
    end
  end
end
