# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Body::DateTimeComponent do
  subject(:cell) { described_class.new(table, record, :created_at) }

  let(:table) { Katalyst::TableComponent.new(collection: Person.all, id: "table") }
  let(:record) { create(:person) }

  before do
    record
  end

  context "when date is today" do
    subject(:cell) { described_class.new(table, record, :created_at) }

    it "renders column" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td title="#{I18n.l(record.created_at.to_datetime, format: :table)}">Less than a minute ago</td>
      HTML
    end
  end

  context "when an hour ago" do
    subject(:cell) { described_class.new(table, record, :created_at) }

    let(:record) { create(:person, created_at: 1.hour.ago) }

    it "renders column" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td title="#{I18n.l(record.created_at.to_datetime, format: :table)}">About 1 hour ago</td>
      HTML
    end
  end

  context "when not relative" do
    subject(:cell) { described_class.new(table, record, :created_at, relative: false) }

    let(:record) { create(:person, created_at: Date.current) }

    it "renders column" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td>#{I18n.l(record.created_at.to_datetime, format: :table)}</td>
      HTML
    end
  end

  context "when future date" do
    subject(:cell) { described_class.new(table, record, :created_at) }

    let(:record) { create(:person, created_at: 1.hour.from_now) }

    it "renders column" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td title="#{I18n.l(record.created_at.to_datetime, format: :table)}">About 1 hour from now</td>
      HTML
    end
  end

  context "with nil values" do
    let(:record) { build(:resource, created_at: nil) }

    it "renders as a string" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td></td>
      HTML
    end
  end

  context "when given a block" do
    it "renders the block's value" do
      expect(render_inline(cell) { "BLOCK" }).to match_html(<<~HTML)
        <td title="#{I18n.l(record.created_at.to_datetime, format: :table)}">BLOCK</td>
      HTML
    end

    it "allows block to access value" do
      expect(render_inline(cell) { |cell| I18n.l(cell.value, format: :long) }).to match_html(<<~HTML)
        <td title="#{I18n.l(record.created_at.to_datetime, format: :table)}">#{I18n.l(record.created_at.to_datetime, format: :long)}</td>
      HTML
    end
  end

  context "with html_options" do
    subject(:cell) { described_class.new(table, record, :created_at, **Test::HTML_ATTRIBUTES) }

    it "renders tag with html_options" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL" title="#{I18n.l(record.created_at.to_datetime, format: :table)}">Less than a minute ago</td>
      HTML
    end
  end
end
