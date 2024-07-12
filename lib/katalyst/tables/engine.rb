# frozen_string_literal: true

require "katalyst/html_attributes"
require "rails/engine"
require "view_component"

module Katalyst
  module Tables
    class Engine < ::Rails::Engine # :nodoc:
      isolate_namespace Katalyst::Tables
      config.eager_load_namespaces << Katalyst::Tables
      config.paths.add("lib", autoload: true)

      initializer "katalyst-tables.asset" do
        config.after_initialize do |app|
          if app.config.respond_to?(:assets)
            app.config.assets.precompile += %w[katalyst-tables.js]
          end
        end
      end

      initializer "katalyst-tables.importmap", before: "importmap" do |app|
        if app.config.respond_to?(:importmap)
          app.config.importmap.paths << root.join("config/importmap.rb")
          app.config.importmap.cache_sweepers << root.join("app/assets/builds")
        end
      end

      initializer "katalyst-tables.collection-types" do |app|
        app.reloader.to_prepare do
          Tables.config.collection_types.each do |key, type|
            Collection::Type.register(key, type.constantize)
          end
        end
      end
    end
  end
end
