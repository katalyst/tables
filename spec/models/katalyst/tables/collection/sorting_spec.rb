# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Sorting do
  subject(:collection) { base.new(sorting: "name asc").with_params(params) }

  let(:base) { Katalyst::Tables::Collection::Base }
  let(:items) { Person.all }
  let(:params) { ActionController::Parameters.new }

  it { is_expected.not_to be_filtered }
  it { is_expected.to have_attributes(to_params: {}) }

  it "applies default sort" do
    allow(items).to receive(:reorder).and_return(items)
    collection.apply(items)
    expect(items).to have_received(:reorder).with("name" => "asc")
  end

  context "when no sorting config is provided" do
    subject(:collection) { base.with_params(params) }

    it "does not sort" do
      allow(items).to receive(:reorder).and_return(items)
      collection.apply(items)
      expect(items).not_to have_received(:reorder)
    end
  end

  context "with sort config" do
    subject(:collection) do
      Class.new(base) do
        config.sorting = :name
      end.with_params(params)
    end

    it { is_expected.not_to be_filtered }
    it { is_expected.to have_attributes(to_params: {}) }

    it "applies default sort" do
      allow(items).to receive(:reorder).and_return(items)
      collection.apply(items)
      expect(items).to have_received(:reorder).with("name" => "asc")
    end
  end

  context "with sort url params" do
    let(:params) { ActionController::Parameters.new(sort: "name desc") }

    it { is_expected.not_to be_filtered }
    it { is_expected.to have_attributes(to_params: { "sort" => "name desc" }) }

    it "applies specified sort" do
      allow(items).to receive(:reorder).and_return(items)
      collection.apply(items)
      expect(items).to have_received(:reorder).with("name" => "desc")
    end
  end

  context "with default sort url as params" do
    let(:params) { ActionController::Parameters.new(sort: "name asc") }

    it { is_expected.not_to be_filtered }
    it { is_expected.to have_attributes(to_params: {}) }
  end

  context "when sorting by scope" do
    let(:params) { ActionController::Parameters.new(sort: "col asc") }

    it "calls scope" do
      allow(items).to receive_messages(reorder: items, order_by_col: items)
      collection.apply(items)
      expect(items).to have_received(:order_by_col).with(:asc)
    end
  end

  context "when sorting by scope descending" do
    let(:params) { ActionController::Parameters.new(sort: "col desc") }

    it "sorts by desc" do
      allow(items).to receive_messages(reorder: items, order_by_col: items)
      collection.apply(items)
      expect(items).to have_received(:order_by_col).with(:desc)
    end
  end

  describe "#sortable?" do
    # sortable? is only supported when items are available
    before { collection.apply(items) }

    it { is_expected.to be_sortable(:name) }
    it { is_expected.not_to be_sortable(:unknown) }

    it "supports sorting via scopes" do
      allow(Person).to receive(:order_by_col).and_return(Person.all)
      expect(collection).to be_sortable(:col)
    end
  end

  describe "#sort_status" do
    # sort_status is only supported when items are available
    before { collection.apply(items) }

    it { expect(collection.sort_status("name")).to eq "asc" }

    context "with desc" do
      let(:params) { { sort: "name desc" } }

      it { expect(collection.sort_status("name")).to eq "desc" }
    end

    context "with another column" do
      let(:params) { { sort: "other desc" } }

      it { expect(collection.sort_status("name")).to be_nil }
    end
  end

  describe "#toggle_sort" do
    # toggle_sort is only supported when items are available
    before { collection.apply(items) }

    it { expect(collection.toggle_sort("name")).to eq("name desc") }

    context "with desc" do
      let(:params) { { sort: "name desc" } }

      it { expect(collection.toggle_sort("name")).to eq("name asc") }
    end

    context "with another column" do
      let(:params) { { sort: "other asc" } }

      it { expect(collection.toggle_sort("name")).to eq("name asc") }
    end
  end
end
