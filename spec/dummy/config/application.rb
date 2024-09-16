# frozen_string_literal: true

require_relative "boot"

require "rails"

require "active_model/railtie"
require "action_controller/railtie"
require "active_record/railtie"
require "action_view/railtie"
require "action_text/engine"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults Rails::VERSION::STRING.to_f

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Adelaide"

    # Dummy testing without eager load enabled
    config.eager_load = false

    # Don't generate system test files.
    config.generators.system_tests = nil

    # https://github.com/ViewComponent/view_component/issues/1565
    ViewComponent::Base.config.view_component_path = "app/components"
    ViewComponent::Base.config.test_controller = "ApplicationController"
  end
end
