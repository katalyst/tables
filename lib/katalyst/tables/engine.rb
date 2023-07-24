# frozen_string_literal: true

require "rails"

module Katalyst
  module Tables
    class Engine < ::Rails::Engine # :nodoc:
      isolate_namespace Katalyst::Tables

      initializer "katalyst-tables.asset" do
        config.after_initialize do |app|
          app.config.assets.precompile += %w[katalyst-tables.js] if app.config.respond_to?(:assets)
        end
      end

      initializer "katalyst-tables.importmap", before: "importmap" do |app|
        if app.config.respond_to?(:importmap)
          app.config.importmap.paths << root.join("config/importmap.rb")
          app.config.importmap.cache_sweepers << root.join("app/assets/javascripts")
        end
      end
    end
  end
end
