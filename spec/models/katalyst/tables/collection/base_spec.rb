# frozen_string_literal: true

require "rails_helper"

require_relative "../../../../support/collection_examples"

RSpec.describe Katalyst::Tables::Collection::Base do
  subject(:collection) { described_class.new }

  let(:items) { build(:relation, count: 50) }

  it "does not paginate by default" do
    expect(collection.apply(items).items).to have_attributes(count: 50)
  end

  context "with pagination config" do
    subject(:collection) do
      Class.new(described_class) do
        config.paginate = true
      end.new
    end

    it "applies pagination" do
      expect(collection.apply(items).items).to have_attributes(count: 20)
    end
  end

  context "with pagination item count config" do
    subject(:collection) do
      klass                 = Class.new(described_class)
      klass.config.paginate = { items: 10 }
      klass.new
    end

    it "applies pagination" do
      expect(collection.apply(items).items).to have_attributes(count: 10)
    end

    it "does not mutate class options" do
      collection.apply(items)
      expect(collection.config.paginate).not_to include(page: anything)
    end
  end

  context "with pagination options" do
    subject(:collection) { described_class.new(paginate: true) }

    it "applies pagination" do
      expect(collection.apply(items).items).to have_attributes(count: 20)
    end
  end

  context "with pagy options" do
    subject(:collection) { described_class.new(paginate: { items: 10 }) }

    it "applies options" do
      expect(collection.apply(items).items).to have_attributes(count: 10)
    end
  end

  context "with pagination params" do
    subject(:collection) { described_class.new(paginate: true).with_params(params) }

    let(:params) { ActionController::Parameters.new(page: 2) }

    it "accepts page param" do
      expect(collection.apply(items)).to have_attributes(page: 2)
    end

    it "passes param to pagy" do
      expect(collection.apply(items).pagination).to have_attributes(page: 2)
    end

    it "applies pagination" do
      collection.apply(items)
      expect(items).to have_received(:offset).with(20)
    end
  end

  it "does not sort by default" do
    collection.apply(items)
    expect(items).not_to have_received(:reorder)
  end

  context "with sort config" do
    subject(:collection) do
      Class.new(described_class) do
        config.sorting = :name
      end.new
    end

    it "applies default sort" do
      collection.apply(items)
      expect(items).to have_received(:reorder).with("name" => "asc")
    end
  end

  context "with sort options" do
    subject(:collection) { described_class.new(sorting: "name desc") }

    it "applies default sort" do
      collection.apply(items)
      expect(items).to have_received(:reorder).with("name" => "desc")
    end
  end

  context "with sort url params" do
    subject(:collection) { described_class.new(sorting: "name").with_params(params) }

    let(:params) { ActionController::Parameters.new(sort: "index desc") }

    it "applies specified sort" do
      collection.apply(items)
      expect(items).to have_received(:reorder).with("index" => "desc")
    end
  end

  context "with custom filter" do
    subject(:collection) do
      Examples::SearchCollection.new.with_params(params)
    end

    let(:params) { ActionController::Parameters.new(search: "query") }

    it "applies filter" do
      allow(items).to receive(:search).and_return(items)
      collection.apply(items)
      expect(items).to have_received(:search).with("query")
    end
  end

  context "with array params" do
    subject(:collection) do
      Examples::TagsCollection.new.with_params(params)
    end

    let(:params) { ActionController::Parameters.new(tags: %w[foo bar]) }

    it "permits array params" do
      allow(items).to receive(:with_tags).and_return(items)
      collection.apply(items)
      expect(items).to have_received(:with_tags).with(%w[foo bar])
    end
  end

  context "with custom permitted params" do
    subject(:collection) do
      Examples::CustomParamsCollection.new.with_params(params)
    end

    let(:params) { ActionController::Parameters.new(custom: "test") }

    it "permits custom" do
      allow(items).to receive(:with_custom).and_return(items)
      collection.apply(items)
      expect(items).to have_received(:with_custom).with("test")
    end
  end

  context "with nested params" do
    subject(:collection) do
      Examples::NestedCollection.new.with_params(params)
    end

    let(:params) { ActionController::Parameters.new(nested: { custom: "test" }) }

    it "permits custom" do
      allow(items).to receive(:filter_by).and_return(items)
      collection.apply(items)
      expect(items).to have_received(:filter_by).with(have_attributes(custom: "test"))
    end
  end

  context "with sort, paginate, and filter options" do
    subject(:collection) do
      Examples::SearchCollection.new(sorting: "name", paginate: true).with_params(params)
    end

    let(:params) { ActionController::Parameters.new(search: "query") }

    it "applies filtering then sort then pagination" do # rubocop:disable RSpec/MultipleExpectations
      items = spy(ActiveRecord::Relation) # rubocop:disable RSpec/VerifiedDoubles
      model = spy(Resource) # rubocop:disable RSpec/VerifiedDoubles
      allow(items).to receive_messages(model: model, count: 50)
      allow(model).to receive(:has_attribute?).and_return(true)

      collection.apply(items)

      expect(items).to have_received(:search).ordered # filter
      expect(items).to have_received(:reorder).ordered # sort
      expect(items).to have_received(:offset).ordered # pagination
      expect(items).to have_received(:limit).ordered # pagination
    end
  end

  describe "#filtered?" do
    subject(:collection) do
      Examples::SearchCollection.new(sorting: "name", paginate: true).with_params(params)
    end

    let(:params) { ActionController::Parameters.new }

    it { is_expected.not_to be_filtered }

    context "with filter" do
      let(:params) { ActionController::Parameters.new(search: "test") }

      it { is_expected.to be_filtered }
    end

    context "with sort" do
      let(:params) { ActionController::Parameters.new(sort: "name desc") }

      it { is_expected.not_to be_filtered }
    end

    context "with page" do
      let(:params) { ActionController::Parameters.new(page: "2") }

      it { is_expected.not_to be_filtered }
    end

    context "with empty array params" do
      subject(:collection) do
        Examples::TagsCollection.new.with_params(ActionController::Parameters.new(tags: []))
      end

      it { is_expected.not_to be_filtered }
    end

    context "with array params present" do
      subject(:collection) do
        Examples::TagsCollection.new.with_params(ActionController::Parameters.new(tags: %w[foo bar]))
      end

      it { is_expected.to be_filtered }
    end

    context "with empty nested params" do
      subject(:collection) do
        Examples::NestedCollection.new.with_params(ActionController::Parameters.new(nested: { custom: "" }))
      end

      it { is_expected.not_to be_filtered }
    end

    context "with nested params present" do
      subject(:collection) do
        Examples::NestedCollection.new.with_params(ActionController::Parameters.new(nested: { custom: "test" }))
      end

      it { is_expected.to be_filtered }
    end
  end

  describe "#sorting" do
    subject(:collection) { described_class.new(sorting: "name") }

    let(:params) { ActionController::Parameters.new(sort: "name desc") }

    it { is_expected.to have_attributes(sort: "name asc") }

    context "with sort param provided" do
      subject(:collection) { described_class.new(sorting: "name").with_params(params) }

      it { is_expected.to have_attributes(sort: "name desc") }
    end

    context "with no sorting option" do
      subject(:collection) { described_class.new }

      it { is_expected.to have_attributes(sort: nil) }
    end

    context "with no sorting option and sort param provided" do
      subject(:collection) { described_class.new.with_params(params) }

      it { is_expected.to have_attributes(sort: nil) }
    end
  end

  describe "#to_params" do
    subject(:collection) do
      klass = Class.new(described_class)
      klass.attribute(:search, :string, default: "")
      klass.new(sorting: "name", paginate: true).with_params(params)
    end

    let(:params) { ActionController::Parameters.new }

    it { is_expected.to have_attributes(to_params: {}) }

    context "with filter" do
      let(:params) { ActionController::Parameters.new(search: "test") }

      it { is_expected.to have_attributes(to_params: { "search" => "test" }) }
    end

    context "with sort" do
      let(:params) { ActionController::Parameters.new(sort: "name desc") }

      it { is_expected.to have_attributes(to_params: { "sort" => "name desc" }) }
    end

    context "with page" do
      let(:params) { ActionController::Parameters.new(page: "2") }

      it { is_expected.to have_attributes(to_params: { "page" => 2 }) }
    end

    context "with unchanged defaults" do
      let(:params) { ActionController::Parameters.new(page: "1", sort: "name asc", search: "") }

      it { is_expected.to have_attributes(to_params: {}) }
    end
  end
end
