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

        register(:boolean, ActiveModel::Type::Boolean)
        register(:date, Type::Date)
        register(:decimal, ActiveModel::Type::Decimal)
        register(:float, ActiveModel::Type::Float)
        register(:integer, ActiveModel::Type::Integer)
        register(:string, ActiveModel::Type::String)
      end
    end
  end
end
