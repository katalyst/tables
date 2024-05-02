# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Body::RichTextComponent do
  subject(:cell) { described_class.new(table, record, :answer) }

  let(:table) { Katalyst::TableComponent.new(collection: Faq.all, id: "table") }
  let(:record) { build(:faq) }

  before do
    record
  end

  it "renders column" do
    expect(render_inline(cell)).to match_html(<<~HTML)
      <td title="#{record.answer.to_plain_text}">#{record.answer}</td>
    HTML
  end

  context "with nil values" do
    let(:record) { build(:faq, answer: nil) }

    it "renders as a string" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td title=""></td>
      HTML
    end
  end

  context "when given a block" do
    it "renders the block's value" do
      expect(render_inline(cell) { "BLOCK" }).to match_html(<<~HTML)
        <td title="#{record.answer.to_plain_text}">BLOCK</td>
      HTML
    end

    it "allows block to access value" do
      expect(render_inline(cell) { |cell| cell.value.to_s }).to match_html(<<~HTML)
        <td title="#{record.answer.to_plain_text}">#{record.answer}</td>
      HTML
    end
  end

  context "with html_options" do
    subject(:cell) { described_class.new(table, record, :answer, **Test::HTML_ATTRIBUTES) }

    it "renders tag with html_options" do
      expect(render_inline(cell)).to match_html(<<~HTML)
        <td id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL" title="#{record.answer.to_plain_text}">#{record.answer}</td>
      HTML
    end
  end
end
