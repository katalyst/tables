# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::SummaryTableComponent do
  subject(:component) { described_class.new(model:) }

  let(:model) { create(:person, name: "test") }

  let(:table) { render_inline(component) { |row| row.text(:name) } }

  it "renders a summary tables" do
    expect(table).to match_html(<<~HTML)
      <table class="katalyst--summary-table">
        <tbody>
          <tr>
            <th>Name</th>
            <td>test</td>
          </tr>
        </tbody>
      </table>
    HTML
  end

  context "when html attributes are passed to header cell" do
    let(:table) do
      render_inline(component) do |row|
        row.text :name, **(row.header? ? Test::HTML_ATTRIBUTES : {})
      end
    end

    it "adds html options to header cell tag" do
      expect(table).to match_html(<<~HTML)
        <table class="katalyst--summary-table">
          <tbody>
            <tr>
              <th id="ID" aria-label="LABEL" class="CLASS" data-foo="bar" style="style">Name</th>
              <td>test</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end

  context "when html attributes are passed to body cell" do
    let(:table) do
      render_inline(component) do |row|
        row.text :name, **(row.body? ? Test::HTML_ATTRIBUTES : {})
      end
    end

    it "adds html options to body cell tag" do
      expect(table).to match_html(<<~HTML)
        <table class="katalyst--summary-table">
          <tbody>
            <tr>
              <th>Name</th>
              <td id="ID" aria-label="LABEL" class="CLASS" data-foo="bar" style="style">test</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end
end
