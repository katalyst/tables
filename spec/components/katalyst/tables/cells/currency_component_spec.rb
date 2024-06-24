# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Cells::CurrencyComponent do
  let(:table) { Katalyst::TableComponent.new(collection:) }
  let(:collection) { build_list(:resource, 1, count: 1) }
  let(:rendered) { render_inline(table) { |row| row.currency(:count) } }
  let(:label) { rendered.at_css("thead th") }
  let(:data) { rendered.at_css("tbody td") }

  def test_model(value, &block)
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      def self.model_name
        ActiveModel::Name.new(self, nil, "Test")
      end

      instance_eval(&block)
    end
    [klass.new(count: value)]
  end

  it "renders column header" do
    expect(label).to match_html(<<~HTML)
      <th class="type-currency">Count</th>
    HTML
  end

  it "renders column data" do
    expect(data).to match_html(<<~HTML)
      <td class="type-currency">$0.01</td>
    HTML
  end

  context "with html_options" do
    let(:rendered) { render_inline(table) { |row| row.currency(:count, **Test::HTML_ATTRIBUTES) } }

    it "renders header with html_options" do
      expect(label).to match_html(<<~HTML)
        <th id="ID" class="type-currency CLASS" style="style" data-foo="bar" aria-label="LABEL">Count</th>
      HTML
    end

    it "renders data with html_options" do
      expect(data).to match_html(<<~HTML)
        <td id="ID" class="type-currency CLASS" style="style" data-foo="bar" aria-label="LABEL">$0.01</td>
      HTML
    end
  end

  context "when given a label" do
    let(:rendered) { render_inline(table) { |row| row.currency(:count, label: "LABEL") } }

    it "renders header with label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-currency">LABEL</th>
      HTML
    end

    it "renders data without label" do
      expect(data).to match_html(<<~HTML)
        <td class="type-currency">$0.01</td>
      HTML
    end
  end

  context "when given an empty label" do
    let(:rendered) { render_inline(table) { |row| row.currency(:count, label: "") } }

    it "renders header with an empty label" do
      expect(label).to match_html(<<~HTML)
        <th class="type-currency"></th>
      HTML
    end
  end

  context "with nil data value" do
    let(:collection) { build_list(:resource, 1, count: nil) }

    it "renders data as empty" do
      expect(data).to match_html(<<~HTML)
        <td class="type-currency"></td>
      HTML
    end
  end

  context "with a string data value" do
    let(:collection) do
      test_model("invalid") do
        attribute :count, :string
      end
    end

    it "renders data using currency_to_human's convert" do
      expect(data).to match_html(<<~HTML)
        <td class="type-currency">$0.00</td>
      HTML
    end
  end

  context "with float data value" do
    let(:collection) do
      klass = Class.new do
        include ActiveModel::Model
        include ActiveModel::Attributes

        def self.model_name
          ActiveModel::Name.new(self, nil, "Test")
        end

        attribute :count, :float
      end
      [klass.new(count: 1.0)]
    end

    it "renders data as empty" do
      expect(data).to match_html(<<~HTML)
        <td class="type-currency">$1.00</td>
      HTML
    end
  end

  context "with Money data value" do
    let(:collection) do
      stub_const("Money", Class.new do
        attr_accessor :value

        delegate :to_d, to: :value
      end)

      klass = Class.new do
        include ActiveModel::Model
        include ActiveModel::Attributes

        def self.model_name
          ActiveModel::Name.new(self, nil, "Test")
        end

        attribute :count
      end
      [klass.new(count: Money.new.tap { |m| m.value = 1.0 })]
    end

    it "renders data as empty" do
      expect(data).to match_html(<<~HTML)
        <td class="type-currency">$1.00</td>
      HTML
    end
  end

  context "when given a block" do
    let(:rendered) { render_inline(table) { |row| row.currency(:count) { |cell| cell.tag.span(cell) } } }

    it "renders the default header" do
      expect(label).to match_html(<<~HTML)
        <th class="type-currency">Count</th>
      HTML
    end

    it "renders the custom data" do
      expect(data).to match_html(<<~HTML)
        <td class="type-currency"><span>$0.01</span></td>
      HTML
    end
  end

  context "when given a block that uses value" do
    let(:rendered) do
      render_inline(table) do |row|
        row.currency(:count) do |cell|
          cell.tag.span(cell.number_to_currency(cell.value, format: "%n %u"))
        end
      end
    end

    it "allows block to access value" do
      expect(data).to match_html(<<~HTML)
        <td class="type-currency"><span>0.01 $</span></td>
      HTML
    end
  end
end
