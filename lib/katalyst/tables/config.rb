# frozen_string_literal: true

require "active_support/configurable"

module Katalyst
  module Tables
    class Config
      attr_accessor :collection_types,
                    :component_extensions,
                    :date_format,
                    :datetime_format

      def initialize
        self.collection_types = {
          boolean: "Katalyst::Tables::Collection::Type::Boolean",
          date:    "Katalyst::Tables::Collection::Type::Date",
          enum:    "Katalyst::Tables::Collection::Type::Enum",
          float:   "Katalyst::Tables::Collection::Type::Float",
          integer: "Katalyst::Tables::Collection::Type::Integer",
          string:  "Katalyst::Tables::Collection::Type::String",
          query:   "Katalyst::Tables::Collection::Type::Query",
          search:  "Katalyst::Tables::Collection::Type::Search",
        }

        self.component_extensions = %w[
          Katalyst::Tables::Identifiable
          Katalyst::Tables::Orderable
          Katalyst::Tables::Selectable
          Katalyst::Tables::Sortable
        ]

        self.date_format = :default
        self.datetime_format = :default
      end
    end
  end
end
