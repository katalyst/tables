# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Suggestions do
  def new_collection(scope: Resource, **params)
    Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query

      attribute :id, :integer, multiple: true
      attribute :search, :search, scope: :table_search
      attribute :name, :string
      attribute :active, :boolean
      attribute :created_at, :date
      attribute :category, :enum
      attribute :index, :integer
      attribute :"parent.name", :string
      attribute :"parent.id", :integer, multiple: true
    end.new.with_params(params).apply(scope)
  end

  describe "#suggestions" do
    let(:suggestions) { collection.suggestions }

    context "when no position is given" do
      subject(:collection) { new_collection }

      it "lists keys" do
        expect(suggestions).to include(have_attributes(type: :attribute, value: "id"))
      end

      it "omits search" do
        expect(suggestions).not_to include(have_attributes(type: :attribute, value: "search"))
      end

      it "omits unfilterable" do
        expect(suggestions).not_to include(have_attributes(type: :attribute, value: "q"))
      end
    end

    context "when partial input is given" do
      subject(:collection) { new_collection(q: "ac", p: 2) }

      it "lists matching keys" do
        expect(suggestions).to include(have_attributes(type: :attribute, value: "active"))
      end

      it "omits keys that don't match the partial input" do
        expect(suggestions).not_to include(have_attributes(type: :attribute, value: "id"))
      end
    end

    context "when partial input doesn't match keys" do
      subject(:collection) { new_collection(q: "needle", p: 6) }

      it "returns search prompt" do
        expect(suggestions).to contain_exactly(have_attributes(type: :search_value, value: "needle"))
      end

      it "does not include an error" do
        suggestions # side-effect
        expect(collection.errors).to be_empty
      end
    end

    context "when partial input is an unknown key" do
      subject(:collection) { new_collection(q: "needle:", p: 7) }

      it "returns an error" do
        suggestions # side-effect
        expect(collection.errors.where(:query))
          .to include(have_attributes(type: :unknown_key, options: { input: "needle" }))
      end
    end

    context "when partial input doesn't match keys and no search available" do
      let(:collection) do
        Class.new(Katalyst::Tables::Collection::Base) do
          include Katalyst::Tables::Collection::Query

          def self.model_name
            ActiveModel::Name.new(self, nil, "Test")
          end
        end.new.with_params(q: "needle", p: 6).apply(Resource)
      end

      it "returns an empty list" do
        expect(suggestions).to be_empty
      end

      it "returns an error" do
        suggestions # side-effect
        expect(collection.errors.where(:query))
          .to include(have_attributes(type: :no_untagged_search, options: { input: "needle" }))
      end
    end

    context "when cursor is at the beginning of a token" do
      subject(:collection) { new_collection(q: "unknown active unknown", p: 8) }

      it "filters using the whole token" do
        expect(suggestions).to contain_exactly(
          have_attributes(type: :attribute, value: "active"),
          have_attributes(type: :search_value, value: "active"),
        )
      end
    end

    context "when cursor is outside the query string" do
      subject(:collection) { new_collection(q: "input", p: 8) }

      it "returns all suggestions" do
        expect(suggestions).to include(have_attributes(type: :attribute, value: "id"))
      end
    end

    context "when cursor is not inside a token" do
      subject(:collection) { new_collection(q: "a  b", p: 2) }

      it "returns all suggestions" do
        expect(suggestions).to include(have_attributes(type: :attribute, value: "id"))
      end
    end

    context "when cursor is at the end of a valid key" do
      subject(:collection) { new_collection(q: "active:", p: 7) }

      it "returns value suggestions" do
        expect(suggestions).to contain_exactly(
          have_attributes(type: :constant_value, value: true),
          have_attributes(type: :constant_value, value: false),
        )
      end
    end

    context "when retrieving examples from the database" do
      subject(:collection) { new_collection(q: "name:", p: 5) }

      it "limits example count" do
        create_list(:resource, 11) # rubocop:disable FactoryBot/ExcessiveCreateList
        expect(suggestions.map(&:value)).to match_array([1, 10, 11, *(2..8)].map { |n| "Resource #{n}" })
      end

      it "deduplicates values" do
        create_list(:resource, 5, name: "resource")
        expect(suggestions.map(&:value)).to contain_exactly("resource")
      end
    end

    context "when retrieving examples with a filter applied" do
      subject(:collection) { new_collection(q: "example name:", p: 13) }

      it "un-scopes example query" do
        create(:resource)
        expect(suggestions.map(&:value)).to contain_exactly("Resource 1")
      end
    end

    context "when no database suggestions are available" do
      subject(:collection) { new_collection(q: "name:missing", p: 12) }

      it "creates a placeholder term" do
        create(:resource)
        expect(suggestions.map(&:value)).to contain_exactly("missing")
      end
    end

    context "when retrieving examples for complex keys" do
      subject(:collection) { new_collection(q: "parent.name:", p: 12, scope: Nested::Child) }

      it "finds associated values" do
        create_list(:child, 1)
        expect(suggestions).to contain_exactly(have_attributes(type: :database_value, value: "Parent 1"))
      end
    end

    # note: there are more specific value tests are in type specs
  end
end
