# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Base do
  subject(:collection) { described_class.new }

  let(:items) { Person.all }

  it { is_expected.not_to be_filtered }
  it { is_expected.to have_attributes(to_params: {}) }

  context "with custom filter" do
    subject(:collection) do
      Examples::SearchCollection.new.with_params(params)
    end

    let(:params) { ActionController::Parameters.new(search: "query") }

    before do
      allow(items).to receive(:search).and_return(items)
    end

    it { is_expected.to be_filtered }
    it { is_expected.to have_attributes(to_params: { "search" => "query" }) }

    it "applies filter" do
      collection.apply(items)
      expect(items).to have_received(:search).with("query")
    end

    context "when empty" do
      let(:params) { ActionController::Parameters.new(search: "") }

      it { is_expected.not_to be_filtered }
      it { is_expected.to have_attributes(to_params: {}) }

      it "does not apply filter" do
        collection.apply(items)
        expect(items).not_to have_received(:search)
      end
    end
  end

  context "with array params" do
    subject(:collection) do
      Examples::TagsCollection.new.with_params(params)
    end

    let(:params) { ActionController::Parameters.new(tags: %w[foo bar]) }

    before do
      allow(items).to receive(:with_tags).and_return(items)
    end

    it { is_expected.to be_filtered }
    it { is_expected.to have_attributes(to_params: { "tags" => %w[foo bar] }) }

    it "permits array params" do
      collection.apply(items)
      expect(items).to have_received(:with_tags).with(%w[foo bar])
    end

    context "when empty" do
      let(:params) { ActionController::Parameters.new(tags: []) }

      it { is_expected.not_to be_filtered }
      it { is_expected.to have_attributes(to_params: {}) }

      it "does not apply filter" do
        collection.apply(items)
        expect(items).not_to have_received(:with_tags)
      end
    end
  end

  context "with custom permitted params" do
    subject(:collection) do
      Examples::CustomParamsCollection.new.with_params(params)
    end

    let(:params) { ActionController::Parameters.new(custom: "test") }

    before do
      allow(items).to receive(:with_custom).and_return(items)
    end

    it { is_expected.to be_filtered }
    it { is_expected.to have_attributes(to_params: { "custom" => "test" }) }

    it "permits custom" do
      collection.apply(items)
      expect(items).to have_received(:with_custom).with("test")
    end

    context "when empty" do
      let(:params) { ActionController::Parameters.new(custom: "") }

      it { is_expected.not_to be_filtered }
      it { is_expected.to have_attributes(to_params: {}) }

      it "does not apply filter" do
        collection.apply(items)
        expect(items).not_to have_received(:with_custom)
      end
    end
  end

  context "with nested params" do
    subject(:collection) do
      Examples::NestedCollection.new.with_params(params)
    end

    let(:params) { ActionController::Parameters.new(nested: { custom: "test" }) }

    before do
      allow(items).to receive(:filter_by).and_return(items)
    end

    it { is_expected.to be_filtered }
    it { is_expected.to have_attributes(to_params: { "nested" => { "custom" => "test" } }) }

    it "permits custom" do
      collection.apply(items)
      expect(items).to have_received(:filter_by).with(have_attributes(custom: "test"))
    end

    context "when empty" do
      let(:params) { ActionController::Parameters.new(nested: { custom: "" }) }

      it { is_expected.not_to be_filtered }
      it { is_expected.to have_attributes(to_params: {}) }

      it "does not apply filter" do
        collection.apply(items)
        expect(items).not_to have_received(:filter_by)
      end
    end
  end

  context "with sort, paginate, and filter options" do
    subject(:collection) do
      Examples::SearchCollection.new(sorting: "name", paginate: true).with_params(params)
    end

    let(:params) { ActionController::Parameters.new(search: "query") }

    # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength, RSpec/VerifiedDoubles
    it "applies filtering then sort then pagination" do
      items = spy(ActiveRecord::Relation)
      model = spy(Resource)
      allow(items).to receive_messages(model:, count: 50)
      allow(model).to receive(:has_attribute?).and_return(true)

      collection.apply(items)

      expect(items).to have_received(:search).ordered # filter
      expect(items).to have_received(:reorder).ordered # sort
      expect(items).to have_received(:offset).ordered # pagination
      expect(items).to have_received(:limit).ordered # pagination
    end
    # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength, RSpec/VerifiedDoubles
  end
end
