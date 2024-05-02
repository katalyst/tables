# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Pagination do
  subject(:collection) { base.new.with_params(params) }

  let(:base) { Katalyst::Tables::Collection::Base }
  let(:items) { Person.all }
  let(:params) { ActionController::Parameters.new }

  it { is_expected.not_to be_filtered }
  it { is_expected.to have_attributes(to_params: {}) }

  it "does not paginate by default" do
    expect(collection.apply(items)).to have_attributes(count: 0, pagination: nil)
  end

  it "applies default pagination options" do
    expect(collection.apply(items).paginate_options).to eql({ anchor_string: "data-turbo-action=\"replace\"" })
  end

  context "with unchanged defaults" do
    let(:params) { ActionController::Parameters.new(page: "1") }

    it { is_expected.not_to be_filtered }
    it { is_expected.to have_attributes(to_params: {}) }
  end

  context "with page" do
    let(:params) { ActionController::Parameters.new(page: "2") }

    it { is_expected.not_to be_filtered }
    it { is_expected.to have_attributes(to_params: { "page" => 2 }) }
  end

  context "with pagination config" do
    subject(:collection) do
      Class.new(base) do
        config.paginate = true
      end.new
    end

    it "applies pagination" do
      allow(items).to receive(:count).and_return(50)
      expect(collection.apply(items).pagination).to have_attributes(page: 1, items: 20, count: 50)
    end
  end

  context "with pagination item count config" do
    subject(:collection) do
      Class.new(base) do
        config.paginate = { items: 5 }
      end.new
    end

    before { create_list(:person, 6) }

    it "applies pagination" do
      expect(collection.apply(items).items).to have_attributes(count: 5)
    end

    it "updates pagination vars" do
      expect(collection.apply(items).pagination).to have_attributes(page: 1, items: 5, count: 6)
    end

    it "does not mutate class options" do
      collection.apply(items)
      expect(collection.config.paginate).not_to include(page: anything)
    end
  end

  context "with pagination options" do
    subject(:collection) { base.new(paginate: true) }

    it "applies pagination" do
      allow(items).to receive(:count).and_return(50)
      expect(collection.apply(items).pagination).to have_attributes(page: 1, items: 20, count: 50)
    end
  end

  context "with pagy options" do
    subject(:collection) { base.new(paginate: { items: 5, anchor_string: "test" }) }

    it "applies options" do
      allow(items).to receive(:count).and_return(50)
      expect(collection.apply(items).pagination).to have_attributes(page: 1, items: 5, count: 50)
    end

    it "changes default options" do
      expect(collection.apply(items).paginate_options).to eql({ anchor_string: "test", items: 5 })
    end
  end

  context "with pagination params" do
    subject(:collection) { base.new(paginate: true).with_params(params) }

    let(:params) { ActionController::Parameters.new(page: 2) }

    before do
      allow(items).to receive(:count).and_return(50)
    end

    it "accepts page param" do
      expect(collection.apply(items)).to have_attributes(page: 2)
    end

    it "passes param to pagy" do
      expect(collection.apply(items).pagination).to have_attributes(page: 2, items: 20, count: 50)
    end

    it "applies pagination" do
      allow(items).to receive_messages(count: 50, offset: items)
      collection.apply(items)
      expect(items).to have_received(:offset).with(20)
    end
  end

  describe "#filtered?" do
    subject(:collection) do
      Examples::SearchCollection.new(sorting: "name", paginate: true).with_params(params)
    end

    let(:params) { ActionController::Parameters.new }

    it { is_expected.not_to be_filtered }

    context "with page" do
      let(:params) { ActionController::Parameters.new(page: "2") }

      it { is_expected.not_to be_filtered }
    end
  end

  describe "#to_params" do
    subject(:collection) do
      klass = Class.new(base)
      klass.attribute(:search, :string, default: "")
      klass.new(sorting: "name", paginate: true).with_params(params)
    end

    let(:params) { ActionController::Parameters.new }

    it { is_expected.to have_attributes(to_params: {}) }

    context "with page" do
      let(:params) { ActionController::Parameters.new(page: "2") }

      it { is_expected.to have_attributes(to_params: { "page" => 2 }) }
    end

    context "with unchanged defaults" do
      let(:params) { ActionController::Parameters.new(page: "1") }

      it { is_expected.to have_attributes(to_params: {}) }
    end
  end
end
