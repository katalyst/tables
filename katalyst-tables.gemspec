# frozen_string_literal: true

require_relative "lib/katalyst/tables/version"

Gem::Specification.new do |spec|
  spec.name = "katalyst-tables"
  spec.version = Katalyst::Tables::VERSION
  spec.authors = ["Katalyst Interactive"]
  spec.email = ["devs@katalyst.com.au"]

  spec.summary = "HTML table generator for Rails views"
  spec.description = "Builder-style HTML table generator for building tabular index views. Supports sorting by columns."
  spec.homepage = "https://github.com/katalyst/katalyst-tables"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "N/A"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/katalyst/katalyst-tables"
  spec.metadata["changelog_uri"] = "https://github.com/katalyst/katalyst-tables/blobs/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.2"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
