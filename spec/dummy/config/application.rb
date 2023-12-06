# frozen_string_literal: true

require_relative "boot"

require "rails"

require "active_model/railtie"
require "action_controller/railtie"
require "active_record/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.load_defaults 7.1

    config.autoload_lib(ignore: %w(assets tasks))

    # Tests should not eager load
    config.eager_load = false

    # https://github.com/ViewComponent/view_component/issues/1565
    ViewComponent::Base.config.view_component_path = "app/components"
    ViewComponent::Base.config.test_controller = "ApplicationController"
  end
end
