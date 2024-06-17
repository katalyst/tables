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

        class Filter
          include ActiveRecord::Sanitization::ClassMethods

          def initialize(app)
            @app = app
          end

          def call(collection)
            collection.class._default_attributes.each_value do |attribute|
              key = attribute.name

              next if DEFAULT_ATTRIBUTES.include?(key)

              value = collection.attributes[key]

              filter_attribute(collection, key, value, attribute.type.type)
            end

            @app.call(collection)
          end

          def filter_attribute(collection, key, value, type)
            if key == "search"
              search(collection, value)
            elsif type == :string
              filter_matches(collection, key, value)
            elsif type == :boolean
              filter_eq(collection, key, value) unless value.nil?
            elsif value.present?
              filter_eq(collection, key, value)
            end
          end

          def search(collection, search)
            return if search.blank? || !collection.searchable?

            collection.items = collection.items.public_send(collection.config.search_scope, search)
          end

          def filter_matches(collection, key, value)
            return if value.nil?

            model, column = join_key(collection, key)
            arel_column = model.arel_table[column]

            collection.items = collection.items.where(arel_column.matches("%#{sanitize_sql_like(value)}%"))
          end

          def filter_eq(collection, key, value)
            model, column = join_key(collection, key)

            condition = if model.attribute_types.has_key?(column)
                          model.where(column => value)
                        else
                          model.public_send(column, value)
                        end

            collection.items = collection.items.merge(condition)
          end

          private

          def join_key(collection, key)
            if key.include?(".")
              table, column = key.split(".")
              collection.items = collection.items.joins(table.to_sym)
              [collection.items.reflections[table].klass, column]
            else
              [collection.items.model, key]
            end
          end

          def column_for(key)
            key.include?(".") ? key.split(".").last : key
          end
        end
      end
    end
  end
end
