# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::SortForm do
  # base config: sort specified but not supported
  subject(:form) { described_class.new(**order) }

  let(:collection) { Katalyst::Tables::Collection::Base.new(sort: "name asc").apply(items) }
  let(:items) { Person.all }
  let(:order) { { column: "name", direction: "asc" } }

  describe "#supports?" do
    it { is_expected.not_to be_support(collection, :unknown) }
    it("supports attributes") { is_expected.to be_support(collection, :name) }

    it "supports scopes" do
      allow(Person).to receive(:order_by_col).and_return(Person.all)
      expect(form).to be_support(items, :col)
    end
  end

  describe "#status" do
    it { expect(form.status("name")).to eq "asc" }

    context "with desc" do
      let(:order) { { column: "name", direction: "desc" } }

      it { expect(form.status("name")).to eq "desc" }
    end

    context "with another column" do
      let(:order) { { column: "other", direction: "asc" } }

      it { expect(form.status("col")).to be_nil }
    end
  end

  describe "#toggle" do
    it { expect(form.toggle("name")).to eq("name desc") }

    context "with desc" do
      let(:order) { { column: "name", direction: "desc" } }

      it { expect(form.toggle("name")).to eq("name asc") }
    end

    context "with another column" do
      let(:order) { { column: "other", direction: "asc" } }

      it { expect(form.toggle("name")).to eq("name asc") }
    end
  end

  describe "#apply" do
    # base config: attribute defined and sort present
    subject(:sort) { pair.first }

    let(:pair) { form.apply(items) }
    let(:sorted) { pair.second }

    context "when sort param is undefined" do
      let(:order) { { column: nil, direction: "asc" } }

      it "does not sort collection" do
        allow(items).to receive(:reorder).and_return(items)
        sort
        expect(items).not_to have_received(:reorder)
      end
    end

    context "when sorting by scope" do
      let(:order) { { column: "col", direction: "asc" } }

      it "calls scope" do
        allow(items).to receive(:order_by_col).and_return(items)
        sort
        expect(items).to have_received(:order_by_col).with(:asc)
      end
    end

    context "when sorting by scope descending" do
      let(:order) { { column: "col", direction: "desc" } }

      it "sorts by desc" do
        allow(items).to receive(:order_by_col).and_return(items)
        sort
        expect(items).to have_received(:order_by_col).with(:desc)
      end
    end

    context "when sorting by attribute" do
      it "sorts with reorder" do
        allow(items).to receive(:reorder).and_return(items)
        sort
        expect(items).to have_received(:reorder).with("name" => "asc")
      end
    end

    context "when sorting by attribute descending" do
      let(:order) { { column: "name", direction: "desc" } }

      it "sorts by desc" do
        allow(items).to receive(:reorder).and_return(items)
        sort
        expect(items).to have_received(:reorder).with("name" => "desc")
      end
    end
  end
end
