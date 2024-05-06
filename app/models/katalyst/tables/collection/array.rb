# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      # Entry point for creating a collection from an array for use with table components.
      class Array
        include Core
        include Filtering

        def self.with_params(params)
          new.with_params(params)
        end

        def model
          items.first&.class || ActiveRecord::Base
        end

        def model_name
          @model_name ||= items.first&.model_name || ActiveModel::Name.new(Object, nil, "record")
        end

        def with_params(params)
          # test support
          params = ActionController::Parameters.new(params) unless params.is_a?(ActionController::Parameters)

          self.attributes = params.permit(self.class.permitted_params)

          self
        end

        def inspect
          "#<#{self.class.name} @attributes=#{attributes.inspect} @model_name=\"#{model_name}\" @count=#{items&.count}>"
        end
      end
    end
  end
end
