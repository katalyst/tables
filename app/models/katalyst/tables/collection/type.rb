# frozen_string_literal: true

require "active_model/type"

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
