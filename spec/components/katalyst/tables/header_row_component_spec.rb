# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::HeaderRowComponent do
  subject(:component) { described_class.new }

  let(:table) { Katalyst::TableComponent.new(collection:) }
  let(:collection) { create_list(:person, 1) }
  let(:rendered) { render_inline(table) { |row| row.cell(:name) } }
  let(:row) { rendered.at_css("thead tr") }

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
      <tr><th>Name</td></tr>
    HTML
  end

  it "sets body? to true" do
    expect(component).to have_attributes(body?: false)
  end

  it "sets header? to false" do
    expect(component).to have_attributes(header?: true)
  end

  context "with dom id generation" do
    let(:table) do
      Katalyst::TableComponent.new(collection:, generate_ids: true)
    end
    let(:collection) do
      create_list(:person, 1)
      build(:collection, items: Person.all)
    end

    it "does not generate a dom id" do
      expect(row).to match_html(<<~HTML)
        <tr><th>Name</th></tr>
      HTML
    end
  end
end
