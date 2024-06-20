# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Filtering
        extend ActiveSupport::Concern

        included do
          use(Filter)
        end

        class Filter
          include ActiveRecord::Sanitization::ClassMethods

          def initialize(app)
            @app = app
          end

          def call(collection)
            collection.instance_variable_get(:@attributes).each_value do |attribute|
              collection.items = attribute.type.filter(collection.items, attribute)
            end

            @app.call(collection)
          end
        end
      end
    end
  end
end
