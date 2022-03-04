# frozen_string_literal: true

RSpec.describe Katalyst::Tables::Backend do
  include described_class

  describe "#table_sort" do
    # base config: attribute defined and sort present
    subject(:sort) { pair.first }

    let(:pair) { table_sort(collection) }
    let(:sorted) { pair.second }
    let(:params) { { sort: "col asc" } }

    include_context "with collection"
    include_context "with collection attribute", attribute: "col"

    it "sorts collection" do
      sort
      expect(collection).to have_received(:reorder).with("col" => "asc")
    end

    it "returns sorted" do
      expect(sorted).to be collection
    end

    context "when sort param is not present" do
      let(:params) { {} }

      it "does not sort collection" do
        sort
        expect(collection).not_to have_received(:reorder)
      end
    end

    context "when sort param is unknown" do
      before do
        allow(model).to receive(:has_attribute?).with("col").and_return(false)
      end

      it "checks whether col is defined" do
        sort
        expect(model).to have_received(:has_attribute?).with("col")
      end

      it "does not sort collection" do
        sort
        expect(collection).not_to have_received(:reorder)
      end
    end

    context "when direction is desc" do
      let(:params) { { sort: "col desc" } }

      it "sorts by desc" do
        sort
        expect(collection).to have_received(:reorder).with("col" => "desc")
      end
    end

    context "when direction is unknown" do
      let(:params) { { sort: "col bad" } }

      it "defaults direction to asc" do
        sort
        expect(collection).to have_received(:reorder).with("col" => "asc")
      end
    end

    context "when model has scope" do
      include_context "with collection scope", scope: :order_by_col

      it "calls reorder to reset default (if any)" do
        sort
        expect(collection).to have_received(:reorder).with(nil)
      end

      it "calls scope" do
        sort
        expect(collection).to have_received(:order_by_col).with(:asc)
      end
    end
  end

  describe ".default_table_builder" do
    it "changes the default table builder" do
      expect { self.class.default_table_builder Test::CustomTable }
        .to change(self, :default_table_builder).from(nil).to(Test::CustomTable)
    end
  end
end
