# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::HeaderCellComponent do
  subject(:cell) { described_class.new(table, :name) }

  let(:table) do
    instance_double(Katalyst::TableComponent).tap do |table|
      allow(table).to receive_messages(sorting: sorting, object_name: "resource", collection: items)
    end
  end
  let(:items) { build(:relation) }
  let(:record) { build(:resource, name: "VALUE") }
  let(:sorting) { nil }

  let(:rendered) do
    with_request_url("/resource") do
      render_inline(cell)
    end
  end

  it "renders with titleized key" do
    expect(rendered).to match_html(<<~HTML)
      <th>Name</th>
    HTML
  end

  context "with translation available" do
    it "renders with translation" do
      allow_any_instance_of(described_class)
        .to receive(:translate)
        .with("activerecord.attributes.resource.name", any_args)
        .and_return("TRANSLATED")
      expect(rendered).to match_html(<<~HTML)
        <th>TRANSLATED</th>
      HTML
    end
  end

  context "with sorting" do
    let(:sorting) { Katalyst::Tables::Backend::SortForm.new }

    it "renders with sort link" do
      expect(rendered).to match_html(<<~HTML)
        <th><a href="/resource?sort=name+asc">Name</a></th>
      HTML
    end

    context "when column is not supported" do
      subject(:cell) { described_class.new(table, :unsupported) }

      it "does not add sort link" do
        expect(rendered).to match_html(<<~HTML)
          <th>Unsupported</th>
        HTML
      end
    end

    context "with sorted column" do
      let(:sorting) { Katalyst::Tables::Backend::SortForm.new(column: "name", direction: "desc") }

      it "adds status to data attribute" do
        expect(rendered).to match_html(<<~HTML)
          <th data-sort="desc"><a href="/resource?sort=name+asc">Name</a></th>
        HTML
      end
    end

    context "with sorted column and other data options" do
      subject(:cell) { described_class.new(table, :name, data: { other: "" }) }

      let(:sorting) { Katalyst::Tables::Backend::SortForm.new(column: "name", direction: "asc") }

      it "does not cobber other options" do
        expect(rendered).to match_html(<<~HTML)
          <th data-other data-sort="asc">
            <a href="/resource?sort=name+desc">Name</a>
          </th>
        HTML
      end
    end
  end

  context "with html_options" do
    subject(:cell) { described_class.new(table, :name, **Test::HTML_ATTRIBUTES) }

    it "renders tag with html_options" do
      expect(rendered).to match_html(<<~HTML)
        <th id="ID" class="CLASS" style="style" data-foo="bar" aria-label="LABEL">Name</th>
      HTML
    end
  end

  context "when given a label" do
    subject(:cell) { described_class.new(table, :name, label: "LABEL") }

    it "renders the label" do
      expect(rendered).to match_html(<<~HTML)
        <th>LABEL</th>
      HTML
    end
  end

  context "when given an empty label" do
    subject(:cell) { described_class.new(table, :name, label: "") }

    it "renders an empty cell" do
      expect(rendered).to match_html(<<~HTML)
        <th></th>
      HTML
    end
  end

  context "when given a block" do
    it "renders the default value" do
      # this behaviour is intentional – assumes block is for body rendering, not header
      expect(rendered { "BLOCK" }).to match_html(<<~HTML)
        <th>Name</th>
      HTML
    end
  end
end
