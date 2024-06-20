# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Filtering
        extend ActiveSupport::Concern

        DEFAULT_ATTRIBUTES = %w[sort page query].freeze

        included do
          use(Filter)
        end

        # Internal access to attributes for applying filters to a
        # collection. Not intended for public use.
        def _filter_attributes
          @attributes.except(*DEFAULT_ATTRIBUTES).values
        end

        class Filter
          include ActiveRecord::Sanitization::ClassMethods

          def initialize(app)
            @app = app
          end

          def call(collection)
            collection._filter_attributes.each do |attribute|
              filter_attribute(collection, attribute, attribute.type)
            end

            @app.call(collection)
          end

          def filter_attribute(collection, attribute, type)
            if attribute.name == "search"
              search(collection, attribute)
            elsif type.type == :string
              filter_matches(collection, attribute)
            elsif type.type.in?(%i[boolean date])
              type.filter(collection, attribute)
            elsif attribute.value.present?
              filter_eq(collection, attribute)
            end
          end

          def search(collection, attribute)
            return if attribute.value.blank? || !collection.searchable?

            collection.items = collection.items.public_send(collection.config.search_scope, attribute.value)
          end

          def filter_matches(collection, attribute)
            return if attribute.value.nil?

            model, column = model_and_column_for(collection, attribute)
            arel_column = model.arel_table[column]

            condition = arel_column.matches("%#{sanitize_sql_like(attribute.value)}%")
            collection.items = collection.items.where(condition)
          end

          def filter_date(collection, attribute)
            return if attribute.value.nil?

            model, column = model_and_column_for(collection, attribute)

            condition = if !attribute.valid?
                          model.none
                        elsif model.attribute_types.has_key?(column)
                          model.where(column => attribute.value)
                        else
                          model.public_send(column, attribute.value)
                        end

            collection.items = collection.items.merge(condition)
          end

          def filter_eq(collection, attribute)
            model, column = model_and_column_for(collection, attribute)

            value = attribute.value
            condition = if model.attribute_types.has_key?(column)
                          model.where(column => value)
                        else
                          model.public_send(column, value)
                        end

            collection.items = collection.items.merge(condition)
          end

          private

          def model_and_column_for(collection, attribute)
            if attribute.name.include?(".")
              table, column = attribute.name.split(".")
              collection.items = collection.items.joins(table.to_sym)
              [collection.items.reflections[table].klass, column]
            else
              [collection.items.model, attribute.name]
            end
          end
        end
      end
    end
  end
end
