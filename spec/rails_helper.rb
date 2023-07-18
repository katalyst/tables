# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("dummy/spec/rails_helper", __dir__)

require "rspec/rails"

require "view_component/test_helpers"
require "view_component/system_test_helpers"
require "capybara/rspec"

RSpec.configure do |config|
  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
end
