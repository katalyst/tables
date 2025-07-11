# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "katalyst-tables"
  spec.version = "3.8.3"
  spec.authors = ["Katalyst Interactive"]
  spec.email = ["devs@katalyst.com.au"]

  spec.summary = "HTML table generator for Rails views"
  spec.description = "HTML table generator for building tabular index views with filtering, sorting, and pagination."
  spec.homepage = "https://github.com/katalyst/tables"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/katalyst/tables/blobs/main/CHANGELOG.md"

  spec.files = Dir["{app,config,lib}/**/*", "CHANGELOG.md", "LICENSE.txt", "README.md"]

  spec.require_paths = ["lib"]

  spec.add_dependency "katalyst-html-attributes"
  spec.add_dependency "view_component"
end
