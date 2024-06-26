# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Filter do
  subject(:collection) do
    Class.new(described_class) do
      attribute :search, default: ""

      def filter
        self.items = items.table_search(search) if search.present?
      end
    end.new(sorting: "name", paginate: true).with_params(params)
  end

  let(:items) { Person.all }
  let(:params) { ActionController::Parameters.new }

  it { is_expected.not_to be_filtered }
  it { is_expected.to have_attributes(to_params: {}) }

  context "with filter" do
    let(:params) { ActionController::Parameters.new(filters: { search: "query" }) }

    let(:form) do
      form_with(model: collection, url: "/") do |f|
        f.text_field :search
      end
    end

    it { is_expected.to be_filtered }
    it { is_expected.to have_attributes(to_params: { "filters" => { "search" => "query" } }) }

    it "applies filter" do
      collection.apply(items)
      expect(collection.items.to_sql).to eq(Person.table_search("query").reorder(name: :asc).limit(20).offset(0).to_sql)
    end
  end

  context "with sort, paginate, and filter" do
    let(:params) { ActionController::Parameters.new(filters: { search: "person" }, page: 2, sort: "name desc") }

    it { is_expected.to be_filtered }

    it "includes filters and sort/page params" do
      expect(collection).to have_attributes(to_params: { "filters" => { "search" => "person" },
                                                         "page"    => 2,
                                                         "sort"    => "name desc" })
    end

    it "applies filtering then sort then pagination" do
      create_list(:person, 22) # rubocop:disable FactoryBot/ExcessiveCreateList
      collection.apply(items)
      expect(collection.items.to_sql)
        .to eq(Person.table_search("person").reorder(name: :desc).limit(20).offset(20).to_sql)
    end
  end
end
