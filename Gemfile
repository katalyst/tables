# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in katalyst-tables.gemspec
gemspec

gem "csv"
gem "dartsass-rails"
gem "erb_lint", require: false
gem "factory_bot"
gem "importmap-rails"
gem "nokogiri"
gem "pagy"
gem "propshaft"
gem "puma"
gem "rails"
gem "rake"
gem "rspec-rails"
gem "rubocop-katalyst", require: false
gem "sqlite3"
gem "stimulus-rails"
gem "turbo-rails"
gem "view_component", ">= 4.0.0.alpha.1"

group :development, :test do
  gem "faker"
  gem "ostruct" # workaround for ruby-mine debugging
end

group :test do
  gem "capybara", require: false
  gem "compare-xml"
  gem "cuprite"
  gem "rails-controller-testing"
end
