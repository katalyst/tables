# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Filtering do
  subject(:collection) do
    Class.new(Katalyst::Tables::Collection::Base) do
      attribute :search, default: ""

      def filter
        self.items = items.search(search) if search.present?
      end
    end.new(sorting: "name", paginate: true).with_params(params)
  end

  let(:items) { build(:relation, count: 50) }
  let(:params) { ActionController::Parameters.new }

  it { is_expected.not_to be_filtered }
  it { is_expected.to have_attributes(to_params: {}) }

  context "with filters" do
    let(:params) { ActionController::Parameters.new(search: "query") }

    let(:form) do
      form_with(model: collection, url: "/") do |f|
        f.text_field :search
      end
    end

    before do
      allow(items).to receive(:search).and_return(items)
    end

    it { is_expected.to be_filtered }
    it { is_expected.to have_attributes(to_params: { "search" => "query" }) }

    it "applies filter" do
      collection.apply(items)
      expect(items).to have_received(:search).with("query")
    end
  end

  context "with sort, paginate, and filter" do
    let(:params) { ActionController::Parameters.new(search: "query", page: 2, sort: "name desc") }

    it { is_expected.to be_filtered }

    it "includes filters and sort/page params" do
      expect(collection).to have_attributes(to_params: { "search" => "query",
                                                         "page"   => 2,
                                                         "sort"   => "name desc" })
    end

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
end
