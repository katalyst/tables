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
    end
  end
end
