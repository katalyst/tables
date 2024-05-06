# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in katalyst-tables.gemspec
gemspec

gem "dartsass-rails"
gem "erb_lint", require: false
gem "factory_bot"
gem "importmap-rails"
gem "katalyst-html-attributes", path: "../html-attributes"
gem "nokogiri"
gem "pagy"
gem "propshaft"
gem "puma"
gem "rails"
gem "rake"
gem "rspec-rails"
gem "rubocop-katalyst", require: false
gem "sqlite3", "~> 1.7"
gem "stimulus-rails"
gem "turbo-rails"

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
