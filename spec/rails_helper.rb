# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("dummy/spec/rails_helper", __dir__)

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }

require "rspec/rails"

require "view_component/test_helpers"
require "view_component/system_test_helpers"

RSpec.configure do |config|
  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component

  RSpec::Rails::DIRECTORY_MAPPINGS[:component] = %w[spec components]

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
end
