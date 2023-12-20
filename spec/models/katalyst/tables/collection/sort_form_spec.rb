# frozen_string_literal: true

RSpec.describe Katalyst::Tables::Collection::SortForm do
  # base config: sort specified but not supported
  subject(:form) { described_class.new(**order) }

  let(:items) { build(:relation) }
  let(:order) { { column: "col", direction: "asc" } }

  describe "#supports?" do
    it { is_expected.not_to be_support(items, :col) }

    it_behaves_like "when collection has attribute" do
      it { is_expected.to be_support(items, :col) }
    end

    it_behaves_like "when collection has scope" do
      it { is_expected.to be_support(items, :col) }
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

  describe "#toggle" do
    it { expect(form.toggle("col")).to eq("col desc") }

    context "with desc" do
      let(:order) { { column: "col", direction: "desc" } }

      it { expect(form.toggle("col")).to eq("col asc") }
    end

    context "with another column" do
      let(:order) { { column: "other", direction: "asc" } }

      it { expect(form.toggle("col")).to eq("col asc") }
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
        sort
        expect(items).not_to have_received(:reorder)
      end

      it "returns sorted" do
        expect(sorted).to be items
      end
    end

    it_behaves_like "when collection has scope" do
      it "sorts with scope" do
        sort
        expect(items).to have_received(:order_by_col).with(:asc)
      end

      it "returns sorted" do
        expect(sorted).to be items
      end

      context "when direction is provided" do
        let(:order) { { column: "col", direction: "desc" } }

        it "sorts by desc" do
          sort
          expect(items).to have_received(:order_by_col).with(:desc)
        end
      end
    end

    it_behaves_like "when collection has attribute" do
      it "sorts with reorder" do
        sort
        expect(items).to have_received(:reorder).with("col" => "asc")
      end

      it "returns sorted" do
        expect(sorted).to be items
      end

      context "when direction is provided" do
        let(:order) { { column: "col", direction: "desc" } }

        it "sorts by desc" do
          sort
          expect(items).to have_received(:reorder).with("col" => "desc")
        end
      end
    end
  end
end
