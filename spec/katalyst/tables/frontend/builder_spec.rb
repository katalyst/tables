# frozen_string_literal: true

# rubocop:disable RSpec/MultipleDescribes

RSpec.shared_context "with table" do
  let(:html_options) do
    {
      id: "ID",
      class: "CLASS",
      html: { style: "style" },
      data: { foo: "bar" }
    }
  end
  let(:table) do
    instance_spy(Katalyst::Tables::Frontend::Builder).tap do |table|
      allow(table).to receive_messages(
        template: template,
        sort: nil,
        object_name: :test_record,
        collection: collection
      )
    end
  end
  let(:template) { Test::Template.new }

  include_context "with collection"
end

RSpec.describe Katalyst::Tables::Frontend::Builder::Body::Cell do
  subject(:cell) { described_class.new(table, object, :key) }

  include_context "with table"

  let(:object) { Test::Record.new(key: "VALUE") }

  it "renders the object's attribute value" do
    expect(cell.build).to match_html(<<~HTML)
      <td>VALUE</td>
    HTML
  end

  context "when heading" do
    subject(:cell) { described_class.new(table, object, :key, heading: true) }

    it "renders a table header tag" do
      expect(cell.build).to match_html(<<~HTML)
        <th>VALUE</th>
      HTML
    end
  end

  context "with html_options" do
    subject(:cell) { described_class.new(table, object, :key, **html_options) }

    it "renders tag with html_options" do
      expect(cell.build).to match_html(<<~HTML)
        <td id="ID" class="CLASS" style="style" data-foo="bar">VALUE</td>
      HTML
    end
  end

  context "when given a block" do
    it "renders the block's value" do
      expect(cell.build { "BLOCK" }).to match_html(<<~HTML)
        <td>BLOCK</td>
      HTML
    end

    it "allows block to access value" do
      expect(cell.build { |cell| cell.value.titleize }).to match_html(<<~HTML)
        <td>Value</td>
      HTML
    end
  end

  context "with html_options from args and block" do
    subject(:cell) { described_class.new(table, object, :key, **html_options) }

    it "uses block options instead of args" do
      expect(cell.build do |cell|
        cell.options(id: "BLOCK", data: { block: "" })
        "BLOCK"
      end).to match_html(<<~HTML)
        <td id="BLOCK" data-block="">BLOCK</td>
      HTML
    end
  end
end

RSpec.describe Katalyst::Tables::Frontend::Builder::Header::Cell do
  subject(:cell) { described_class.new(table, nil, :key) }

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
      allow(sort).to receive(:supports?).with(collection, :key).and_return(true)
      allow(sort).to receive(:status).with(:key).and_return(nil)
      allow(sort).to receive(:url_for).with(:key).and_return("https://localhost/resource?sort=key+desc")
    end

    it "renders with sort link" do
      expect(cell.build).to match_html(<<~HTML)
        <th><a href="https://localhost/resource?sort=key+desc">Key</a></th>
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
      expect(cell.build).to match_html(<<~HTML)
        <th data-sort="desc"><a href="https://localhost/resource?sort=key+desc">Key</a></th>
      HTML
    end

    it "supports other data options" do
      allow(sort).to receive(:status).with(:key).and_return(:asc)
      expect(described_class.new(table, nil, :key, data: { other: "" }).build).to match_html(<<~HTML)
        <th data-other data-sort="asc">
          <a href="https://localhost/resource?sort=key+desc">Key</a>
        </th>
      HTML
    end
  end

  context "with html_options" do
    subject(:cell) { described_class.new(table, nil, :key, **html_options) }

    it "renders tag with html_options" do
      expect(cell.build).to match_html(<<~HTML)
        <th id="ID" class="CLASS" style="style" data-foo="bar">Key</th>
      HTML
    end
  end

  context "when given a label" do
    subject(:cell) { described_class.new(table, nil, :key, label: "LABEL") }

    it "renders the label" do
      expect(cell.build).to match_html(<<~HTML)
        <th>LABEL</th>
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

RSpec.describe Katalyst::Tables::Frontend::Builder::Body::Row do
  let(:object) { Test::Record.new(key: "VALUE") }

  include_context "with table"

  it "renders an empty row" do
    expect(described_class.new(table, object).build { "" }).to match_html(<<~HTML)
      <tr></tr>
    HTML
  end

  it "renders cells" do
    expect(described_class.new(table, object).build do |row|
      row.cell(:key) + row.cell(:key)
    end).to match_html(<<~HTML)
      <tr><td>VALUE</td><td>VALUE</td></tr>
    HTML
  end

  it "supports `options` from block" do
    expect(described_class.new(table, object).build do |row|
      row.options(id: "BLOCK", data: { block: "" })
    end).to match_html(<<~HTML)
      <tr id="BLOCK" data-block=""></tr>
    HTML
  end

  it "sets body? to true" do
    expect(described_class.new(table, object).build do |row|
      row.cell(:key) { row.body? }
    end).to match_html(<<~HTML)
      <tr><td>true</td></tr>
    HTML
  end

  it "sets header? to false" do
    expect(described_class.new(table, object).build do |row|
      row.cell(:key) { row.header? }
    end).to match_html(<<~HTML)
      <tr><td>false</td></tr>
    HTML
  end

  it "passes self and object to block" do
    expect(described_class.new(table, object).build do |row, object|
      row.cell(:key) { object.key }
    end).to match_html(<<~HTML)
      <tr><td>VALUE</td></tr>
    HTML
  end
end

RSpec.describe Katalyst::Tables::Frontend::Builder::Header::Row do
  include_context "with table"

  it "renders an empty row" do
    expect(described_class.new(table).build { "" }).to match_html(<<~HTML)
      <tr></tr>
    HTML
  end

  it "renders cells" do
    expect(described_class.new(table).build do |row|
      row.cell(:key) + row.cell(:key)
    end).to match_html(<<~HTML)
      <tr><th>Key</th><th>Key</th></tr>
    HTML
  end

  it "supports `options` from block" do
    expect(described_class.new(table).build do |row|
      row.options(id: "BLOCK", data: { block: "" })
    end).to match_html(<<~HTML)
      <tr id="BLOCK" data-block=""></tr>
    HTML
  end

  it "sets body? to false" do
    expect(described_class.new(table).build do |row|
      row.cell(:key, label: row.body?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>false</th></tr>
    HTML
  end

  it "sets header? to true" do
    expect(described_class.new(table).build do |row|
      row.cell(:key, label: row.header?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>true</th></tr>
    HTML
  end

  it "passes self and nil to block" do
    expect(described_class.new(table).build do |row, object|
      row.cell(:key, label: object.nil?.to_s)
    end).to match_html(<<~HTML)
      <tr><th>true</th></tr>
    HTML
  end
end

# rubocop:enable RSpec/MultipleDescribes
