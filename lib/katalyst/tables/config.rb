# frozen_string_literal: true

require "active_support/configurable"

module Katalyst
  module Tables
    class Config
      include ActiveSupport::Configurable

      config_accessor(:component_extensions) do
        %w[
          Katalyst::Tables::Identifiable
          Katalyst::Tables::Orderable
          Katalyst::Tables::Selectable
          Katalyst::Tables::Sortable
        ]
      end

      config_accessor(:date_format) { :default }
      config_accessor(:datetime_format) { :default }

      config_accessor(:collection_types) do
        {
          boolean: "Katalyst::Tables::Collection::Type::Boolean",
          date:    "Katalyst::Tables::Collection::Type::Date",
          enum:    "Katalyst::Tables::Collection::Type::Enum",
          float:   "Katalyst::Tables::Collection::Type::Float",
          integer: "Katalyst::Tables::Collection::Type::Integer",
          string:  "Katalyst::Tables::Collection::Type::String",
          query:   "Katalyst::Tables::Collection::Type::Query",
          search:  "Katalyst::Tables::Collection::Type::Search",
        }
      end
    end
  end
end
