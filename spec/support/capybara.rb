# frozen_string_literal: true

require "capybara/cuprite"
require "capybara/rspec"

Capybara.default_driver = Capybara.javascript_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app)
end
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  # Rails will set `:selenium` as the runner for system tests by default, but this happens after `before` hooks.
  # We want to use our configured javascript driver and ensure that this is set before
  # our before hooks run so that we can log in (etc).
  config.prepend_before(:all, type: :system) do
    driven_by :cuprite, screen_size: [1920, 1080], options: { headless: true, inspector: false }
  end
end
