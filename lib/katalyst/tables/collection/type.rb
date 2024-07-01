# frozen_string_literal: true

require "active_model/type"

require "katalyst/tables/collection/type/helpers/delegate"
require "katalyst/tables/collection/type/helpers/extensions"
require "katalyst/tables/collection/type/helpers/multiple"
require "katalyst/tables/collection/type/helpers/range"

require "katalyst/tables/collection/type/value"

require "katalyst/tables/collection/type/boolean"
require "katalyst/tables/collection/type/date"
require "katalyst/tables/collection/type/enum"
require "katalyst/tables/collection/type/float"
require "katalyst/tables/collection/type/integer"
require "katalyst/tables/collection/type/query"
require "katalyst/tables/collection/type/search"
require "katalyst/tables/collection/type/string"

module Katalyst
  module Tables
    module Collection
      # Based on ActiveModel::Type – provides a registry for Collection filtering
      module Type
        @registry = ActiveModel::Type::Registry.new

        class << self
          attr_accessor :registry # :nodoc:

          def register(type_name, klass = nil, &)
            registry.register(type_name, klass, &)
          end

          def lookup(...)
            registry.lookup(...)
          end

          def default_value
            @default_value ||= Value.new
          end
        end

        register(:boolean, Type::Boolean)
        register(:date, Type::Date)
        register(:enum, Type::Enum)
        register(:float, Type::Float)
        register(:integer, Type::Integer)
        register(:string, Type::String)
        register(:query, Type::Query)
        register(:search, Type::Search)
      end
    end
  end
end
