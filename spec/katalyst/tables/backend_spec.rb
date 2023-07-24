# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Backend do
  include described_class

  describe "#table_sort" do
    # base config: attribute defined and sort present
    subject(:sort) { pair.first }

    let(:items) { build(:relation) }
    let(:pair) { table_sort(items) }
    let(:sorted) { pair.second }
    let(:params) { { sort: "name asc" } }

    it "sorts collection" do
      sort
      expect(items).to have_received(:reorder).with("name" => "asc")
    end

    it "returns sorted" do
      expect(sorted).to be items
    end

    context "when sort param is not present" do
      let(:params) { {} }

      it "does not sort collection" do
        sort
        expect(items).not_to have_received(:reorder)
      end
    end

    context "when sort param is unknown" do
      before do
        allow(items.model).to receive(:has_attribute?).with("name").and_return(false)
      end

      it "checks whether col is defined" do
        sort
        expect(items.model).to have_received(:has_attribute?).with("name")
      end

      it "does not sort collection" do
        sort
        expect(items).not_to have_received(:reorder)
      end
    end

    context "when direction is desc" do
      let(:params) { { sort: "name desc" } }

      it "sorts by desc" do
        sort
        expect(items).to have_received(:reorder).with("name" => "desc")
      end
    end

    context "when direction is unknown" do
      let(:params) { { sort: "name bad" } }

      it "defaults direction to asc" do
        sort
        expect(items).to have_received(:reorder).with("name" => "asc")
      end
    end

    it_behaves_like "when collection has scope", :name do
      it "calls reorder to reset default (if any)" do
        sort
        expect(items).to have_received(:reorder).with(nil)
      end

      it "calls scope" do
        sort
        expect(items).to have_received(:order_by_name).with(:asc)
      end
    end
  end

  describe ".default_table_component" do
    it "changes the default table component" do
      expect { self.class.default_table_component CustomTableComponent }
        .to change(self, :default_table_component).from(nil).to(CustomTableComponent)
    end
  end
end
