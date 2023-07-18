# frozen_string_literal: true

RSpec.describe Katalyst::Tables::Frontend::Builder::HeaderCell do
  subject(:cell) { described_class.new(table, :key) }

  include_context "with table"

  it "renders with titleized key" do
    expect(cell.build).to match_html(<<~HTML)
      <th>Key</th>
    HTML
  end

  context "with translation available" do
    it "renders with translation" do
      allow(template).to receive(:translate)
        .with("activerecord.attributes.test_record.key", any_args)
        .and_return("KEY")
      expect(cell.build).to match_html(<<~HTML)
        <th>KEY</th>
      HTML
    end
  end

  context "with sort" do
    let(:sort) { instance_double(Katalyst::Tables::Backend::SortForm) }

    before do
      allow(table).to receive(:sort).and_return(sort)
      allow(table).to receive(:request).and_return(request)
      allow(sort).to receive(:supports?).with(collection, :key).and_return(true)
      allow(sort).to receive(:status).with(:key).and_return(nil)
      allow(sort).to receive(:toggle).with(:key).and_return("key asc")
    end

    it "renders with sort link" do
      expect(cell.build).to match_html(<<~HTML)
        <th><a href="/resource?sort=key asc">Key</a></th>
      HTML
    end

    it "does not add sort link if column is not supported" do
      allow(sort).to receive(:supports?).with(collection, :key).and_return(false)
      expect(cell.build).to match_html(<<~HTML)
        <th>Key</th>
      HTML
    end

    it "adds status to data attribute, if specified" do
      allow(sort).to receive(:status).with(:key).and_return(:desc)
      allow(sort).to receive(:toggle).with(:key).and_return("key asc")
      expect(cell.build).to match_html(<<~HTML)
        <th data-sort="desc"><a href="/resource?sort=key asc">Key</a></th>
      HTML
    end

    it "supports other data options" do
      allow(sort).to receive(:status).with(:key).and_return(:asc)
      allow(sort).to receive(:toggle).with(:key).and_return("key desc")
      expect(described_class.new(table, :key, data: { other: "" }).build).to match_html(<<~HTML)
        <th data-other data-sort="asc">
          <a href="/resource?sort=key desc">Key</a>
        </th>
      HTML
    end
  end

  context "with html_options" do
    subject(:cell) { described_class.new(table, :key, **html_options) }

    it "renders tag with html_options" do
      expect(cell.build).to match_html(<<~HTML)
        <th id="ID" class="CLASS" style="style" data-foo="bar">Key</th>
      HTML
    end
  end

  context "when given a label" do
    subject(:cell) { described_class.new(table, :key, label: "LABEL") }

    it "renders the label" do
      expect(cell.build).to match_html(<<~HTML)
        <th>LABEL</th>
      HTML
    end
  end

  context "when given an empty label" do
    subject(:cell) { described_class.new(table, :key, label: "") }

    it "renders an empty cell" do
      expect(cell.build).to match_html(<<~HTML)
        <th></th>
      HTML
    end
  end

  context "when given a block" do
    it "renders the default value" do
      # this behaviour is intentional – assumes block is for body rendering, not header
      expect(cell.build { "BLOCK" }).to match_html(<<~HTML)
        <th>Key</th>
      HTML
    end
  end
end
