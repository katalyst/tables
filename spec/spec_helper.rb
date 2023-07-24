# frozen_string_literal: true

require "katalyst/tables"

require "factory_bot"

require "support/backend_examples"
require "support/frontend_examples"
require "support/match_html"

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
    FactoryBot::Evaluator.include RSpec::Mocks::ExampleMethods
  end
end
