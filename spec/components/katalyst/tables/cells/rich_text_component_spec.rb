# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Cells::RichTextComponent do
  let(:table) { Katalyst::TableComponent.new(collection:) }
  let(:collection) { build_list(:faq, 1) }
  let(:rendered) { render_inline(table) { |row| row.rich_text(:answer) } }
  let(:label) { rendered.at_css("thead th") }
  let(:data) { rendered.at_css("tbody td") }

  it "renders column header" do
    expect(label).to match_html(<<~HTML)
      <th data-cell-type="rich-text">Answer</th>
    HTML
  end

  it "renders column data" do
    expect(data).to match_html(<<~HTML)
      <td data-cell-type="rich-text" title="#{collection.first.answer.to_plain_text}">#{collection.first.answer}</td>
    HTML
  end

  context "with html_options" do
    let(:rendered) { render_inline(table) { |row| row.rich_text(:answer, **Test::HTML_ATTRIBUTES) } }

    it "renders header with html_options" do
      expect(label).to match_html(<<~HTML)
        <th id="ID" data-cell-type="rich-text" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">Answer</th>
      HTML
    end

    it "renders data with html_options" do
      expect(data).to match_html(<<~HTML)
        <td id="ID" data-cell-type="rich-text" class="CLASS" style="style" data-foo="bar" aria-label="LABEL" title="#{collection.first.answer.to_plain_text}">#{collection.first.answer}</td>
      HTML
    end
  end

  context "when given a label" do
    let(:rendered) { render_inline(table) { |row| row.rich_text(:answer, label: "LABEL") } }

    it "renders header with label" do
      expect(label).to match_html(<<~HTML)
        <th data-cell-type="rich-text">LABEL</th>
      HTML
    end

    it "renders data without label" do
      expect(data).to match_html(<<~HTML)
        <td data-cell-type="rich-text" title="#{collection.first.answer.to_plain_text}">#{collection.first.answer}</td>
      HTML
    end
  end

  context "when given an empty label" do
    let(:rendered) { render_inline(table) { |row| row.rich_text(:answer, label: "") } }

    it "renders header with an empty label" do
      expect(label).to match_html(<<~HTML)
        <th data-cell-type="rich-text"></th>
      HTML
    end
  end

  context "with nil data value" do
    let(:collection) { build_list(:faq, 1, answer: nil) }

    it "renders data as empty" do
      expect(data).to match_html(<<~HTML)
        <td data-cell-type="rich-text" title=""></td>
      HTML
    end
  end

  context "when given a block" do
    let(:rendered) { render_inline(table) { |row| row.rich_text(:answer) { |cell| cell.tag.span(cell) } } }

    it "renders the default header" do
      expect(label).to match_html(<<~HTML)
        <th data-cell-type="rich-text">Answer</th>
      HTML
    end

    it "renders the custom data" do
      expect(data).to match_html(<<~HTML)
        <td data-cell-type="rich-text" title="#{collection.first.answer.to_plain_text}"><span>#{collection.first.answer}</span></td>
      HTML
    end
  end
end
