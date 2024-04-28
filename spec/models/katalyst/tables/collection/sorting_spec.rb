# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Sorting do
  subject(:collection) { base.new.with_params(params) }

  before do
    allow(items).to receive(:reorder).and_return(items)
  end

  let(:base) { Katalyst::Tables::Collection::Base }
  let(:items) { Person.all }
  let(:params) { ActionController::Parameters.new }

  it { is_expected.not_to be_filtered }
  it { is_expected.to have_attributes(to_params: {}) }

  it "does not sort by default" do
    collection.apply(items)
    expect(items).not_to have_received(:reorder)
  end

  context "with unchanged defaults" do
    let(:params) { ActionController::Parameters.new(sort: "name asc") }

    it { is_expected.not_to be_filtered }
    it { is_expected.to have_attributes(to_params: {}) }
  end

  context "with sort config" do
    subject(:collection) do
      Class.new(base) do
        config.sorting = :name
      end.new
    end

    it { is_expected.not_to be_filtered }
    it { is_expected.to have_attributes(to_params: {}) }

    it "applies default sort" do
      collection.apply(items)
      expect(items).to have_received(:reorder).with("name" => "asc")
    end
  end

  context "with sort options" do
    subject(:collection) { base.new(sorting: "name desc") }

    it { is_expected.not_to be_filtered }
    it { is_expected.to have_attributes(to_params: {}) }

    it "applies default sort" do
      collection.apply(items)
      expect(items).to have_received(:reorder).with("name" => "desc")
    end
  end

  context "with sort url params" do
    subject(:collection) { base.new(sorting: "name").with_params(params) }

    let(:params) { ActionController::Parameters.new(sort: "name desc") }

    it { is_expected.not_to be_filtered }
    it { is_expected.to have_attributes(to_params: { "sort" => "name desc" }) }

    it "applies specified sort" do
      collection.apply(items)
      expect(items).to have_received(:reorder).with("name" => "desc")
    end
  end

  describe "#sorting" do
    subject(:collection) { base.new(sorting: "name") }

    let(:params) { ActionController::Parameters.new(sort: "name desc") }

    it { is_expected.to have_attributes(sort: "name asc") }

    context "with sort param provided" do
      subject(:collection) { base.new(sorting: "name").with_params(params) }

      it { is_expected.to have_attributes(sort: "name desc") }
    end

    context "with no sorting option" do
      subject(:collection) { base.new }

      it { is_expected.to have_attributes(sort: nil) }
    end

    context "with no sorting option and sort param provided" do
      subject(:collection) { base.new.with_params(params) }

      it { is_expected.to have_attributes(sort: nil) }
    end
  end
end
