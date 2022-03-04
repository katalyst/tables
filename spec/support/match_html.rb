# frozen_string_literal: true

require "compare-xml"
require "nokogiri"

# Source: https://makandracards.com/makandra/505308-rspec-matcher-to-compare-two-html-fragments
RSpec::Matchers.define :match_html do |expected_html, **options|
  match do |actual_html|
    # NOTE: the HTML5 parser silently drops orphaned th/td tags
    expected_doc = Nokogiri::HTML.fragment(expected_html)
    actual_doc = Nokogiri::HTML.fragment(actual_html)

    # Options documented here: https://github.com/vkononov/compare-xml
    default_options = {
      collapse_whitespace: true,
      ignore_attr_order: true,
      ignore_comments: true
    }

    options = default_options.merge(options).merge(verbose: true)

    diff = CompareXML.equivalent?(expected_doc, actual_doc, **options)
    diff.blank?
  end
end
