# frozen_string_literal: true

RSpec.describe Katalyst::Tables::Backend::SortForm do
  # base config: sort specified but not supported
  subject(:form) { described_class.new(self, **order) }

  let(:order) { { column: "col", direction: "asc" } }

  include_context "with collection"

  describe "#supports?" do
    it { is_expected.not_to be_support(collection, :col) }

    context "when model has attribute" do
      include_context "with collection attribute"

      it { is_expected.to be_support(collection, :col) }
    end

    context "when collection has scope" do
      include_context "with collection scope"

      it { is_expected.to be_support(collection, :col) }
    end
  end

  describe "#status" do
    it { expect(form.status("col")).to eq "asc" }

    context "with desc" do
      let(:order) { { column: "col", direction: "desc" } }

      it { expect(form.status("col")).to eq "desc" }
    end

    context "with another column" do
      let(:order) { { column: "other", direction: "asc" } }

      it { expect(form.status("col")).to be_nil }
    end
  end

  describe "#url_for" do
    before do
      allow(self).to receive(:url_for) { |params| params }
    end

    it { expect(form.url_for("col")).to eq(sort: "col desc") }

    context "with desc" do
      let(:order) { { column: "col", direction: "desc" } }

      it { expect(form.url_for("col")).to eq(sort: "col asc") }
    end

    context "with another column" do
      let(:order) { { column: "other", direction: "asc" } }

      it { expect(form.url_for("col")).to eq(sort: "col asc") }
    end
  end

  describe "#apply" do
    # base config: attribute defined and sort present
    subject(:sort) { pair.first }

    let(:pair) { form.apply(collection) }
    let(:sorted) { pair.second }

    context "when sort param is undefined" do
      let(:order) { { column: nil, direction: "asc" } }

      it "does not sort collection" do
        sort
        expect(collection).not_to have_received(:reorder)
      end

      it "returns sorted" do
        expect(sorted).to be collection
      end
    end

    context "with model scope" do
      include_context "with collection scope"

      it "sorts with scope" do
        sort
        expect(collection).to have_received(:order_by_col).with(:asc)
      end

      it "returns sorted" do
        expect(sorted).to be collection
      end
    end

    context "with model scope and direction" do
      let(:order) { { column: "col", direction: "desc" } }

      include_context "with collection scope"

      it "sorts by desc" do
        sort
        expect(collection).to have_received(:order_by_col).with(:desc)
      end
    end

    context "with model attribute" do
      include_context "with collection attribute"

      it "sorts with reorder" do
        sort
        expect(collection).to have_received(:reorder).with("col" => "asc")
      end

      it "returns sorted" do
        expect(sorted).to be collection
      end
    end

    context "with model attribute and direction" do
      let(:order) { { column: "col", direction: "desc" } }

      include_context "with collection attribute"

      it "sorts by desc" do
        sort
        expect(collection).to have_received(:reorder).with("col" => "desc")
      end
    end
  end
end
