# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Body::AttachmentComponent do
  subject(:cell) { described_class.new(table, record, :image) }

  let(:table) { Katalyst::TableComponent.new(collection: Resource.all, id: "table") }
  let(:record) { create(:resource, :with_image) }

  before do
    record
  end

  it "renders column" do
    expect(render_inline(cell)).to have_css("td > img[src*='dummy.png']")
  end

  context "with nil values" do
    let(:record) { build(:resource, image: nil) }

    it "renders as a string" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td></td>
      HTML
    end
  end

  context "when given a block" do
    it "renders the block's value" do
      expect(render_inline(cell) { "BLOCK" }).to match_html(<<~HTML)
        <td>BLOCK</td>
      HTML
    end
  end

  context "with html_options" do
    subject(:cell) { described_class.new(table, record, :image, **Test::HTML_ATTRIBUTES) }

    it "renders tag with html_options" do
      expect(render_inline(cell)).to have_css("td.CLASS[data-foo] > img[src*='dummy.png']")
    end
  end
end
