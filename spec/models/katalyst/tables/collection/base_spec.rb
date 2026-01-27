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

    it { is_expected.to be_filtered }
    it { is_expected.to have_attributes(to_params: { "search" => "query" }) }

    it "applies filter" do
      collection.apply(items)
      expect(collection.items.to_sql).to eq(Person.table_search("query").to_sql)
    end

    context "when empty" do
      let(:params) { ActionController::Parameters.new(search: "") }

      it { is_expected.not_to be_filtered }
      it { is_expected.to have_attributes(to_params: {}) }

      it "does not apply filter" do
        collection.apply(items)
        expect(collection.items.to_sql).to eq(Person.all.to_sql)
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

  context "with sort, paginate, and filter" do
    subject(:collection) do
      Examples::SearchCollection.new(sorting: "name", paginate: true).with_params(params)
    end

    let(:params) { ActionController::Parameters.new(search: "person", page: 2, sort: "name desc") }

    it { is_expected.to be_filtered }

    it "includes filters and sort/page params" do
      expect(collection).to have_attributes(to_params: { "search" => "person",
                                                         "page"   => 2,
                                                         "sort"   => "name desc" })
    end

    it "applies filtering then sort then pagination" do
      create_list(:person, 22) # rubocop:disable FactoryBot/ExcessiveCreateList
      collection.apply(items)
      expect(collection.items.to_sql)
        .to eq(Person.table_search("person").reorder(name: :desc).limit(20).offset(20).to_sql)
    end
  end

  context "with a subclass that overrides config" do
    let(:superclass) do
      Class.new(described_class) do
        config.sorting = %i[col1 col2]
      end
    end
    let!(:subclass) do
      Class.new(superclass) do
        config.sorting.push(:col3)
      end
    end

    it { expect(subclass.config.sorting).to eq(%i[col1 col2 col3]) }

    it "does not modify superclass config" do
      expect(superclass.config.sorting).to eq(%i[col1 col2])
    end
  end
end
