# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::CellComponent do
  context "with a header row" do
    subject(:component) do
      described_class.new(collection:, row:, column: :name, record: nil, label: nil, heading: false)
    end

    let(:collection) { Katalyst::Tables::Collection::Base.new.apply(Person.all) }
    let(:row) { Katalyst::Tables::HeaderRowComponent.new }

    it { is_expected.to be_heading }
    it("has a label") { expect(component).to have_attributes(label: "Name") }
    it("has no data") { expect(component).to have_attributes(value: nil, rendered_value: nil, to_s: nil) }

    describe "#call" do
      it "renders label" do
        expect(render_inline(component)).to match_html("<th>Name</th>")
      end

      it "renders html attributes" do
        component.html_attributes = { class: "center" }
        expect(render_inline(component)).to match_html('<th class="center">Name</th>')
      end

      it "supports content wrapping" do # rubocop:disable RSpec/ExampleLength
        wrapper = Class.new(ViewComponent::Base) do
          def self.name
            "TestWrapper"
          end

          def call
            content_tag(:span, content)
          end
        end
        component.with_content_wrapper(wrapper.new)
        expect(render_inline(component)).to match_html("<th><span>Name</span></th>")
      end
    end
  end

  context "with a data row" do
    subject(:component) do
      described_class.new(collection:, row:, column: :name, record: collection.items.first, label: nil, heading: false)
    end

    let(:collection) { Katalyst::Tables::Collection::Array.new.apply(create_list(:person, 1, name: "Bobby>")) }
    let(:row) { Katalyst::Tables::BodyRowComponent.new }

    it { is_expected.not_to be_heading }

    it "has no label" do
      expect(component).to have_attributes(label: nil)
    end

    it "has data" do
      expect(component).to have_attributes(
        value:          "Bobby>",
        rendered_value: "Bobby&gt;",
        to_s:           "Bobby&gt;",
      )
    end

    context "when heading is set" do
      subject(:component) do
        described_class.new(collection:, row:, column: :name, record: collection.items.first, label: nil, heading: true)
      end

      it { is_expected.to be_heading }

      it "renders with th tag" do
        expect(render_inline(component)).to match_html("<th>Bobby&gt;</th>")
      end
    end

    describe "#call" do
      it "renders value" do
        expect(render_inline(component)).to match_html("<td>Bobby&gt;</td>")
      end

      it "renders html attributes" do
        component.html_attributes = { class: "center" }
        expect(render_inline(component)).to match_html('<td class="center">Bobby&gt;</td>')
      end

      it "supports content wrapping" do # rubocop:disable RSpec/ExampleLength
        wrapper = Class.new(ViewComponent::Base) do
          def self.name
            "TestWrapper"
          end

          def call
            content_tag(:span, content)
          end
        end
        component.with_content_wrapper(wrapper.new)
        expect(render_inline(component)).to match_html("<td><span>Bobby&gt;</span></td>")
      end
    end
  end
end
