# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::BodyRowComponent do
  subject(:component) { described_class.new }

  let(:table) { Katalyst::TableComponent.new(collection:) }
  let(:collection) { create_list(:person, 1) }
  let(:rendered) { render_inline(table) { |row| row.cell(:name) } }
  let(:row) { rendered.at_css("tbody tr") }

  context "with an empty table" do
    let(:rendered) { render_inline(table) { nil } }

    it "renders an empty row" do
      expect(row).to match_html(<<~HTML)
        <tr></tr>
      HTML
    end
  end

  it "renders cells" do
    expect(row).to match_html(<<~HTML)
      <tr><td>Person 1</td></tr>
    HTML
  end

  it "sets body? to true" do
    expect(component).to have_attributes(body?: true)
  end

  it "sets header? to false" do
    expect(component).to have_attributes(header?: false)
  end
end
