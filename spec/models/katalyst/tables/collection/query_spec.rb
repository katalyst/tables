# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Query do
  subject(:collection) do
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
    end.new
  end

  it "supports empty query" do
    collection.with_params(q: "")
    expect(collection.filters).to eq({})
  end

  it "drops unsupported tags" do
    collection.with_params(q: "unknown:true")
    expect(collection.filters).to eq({})
  end

  describe "search" do
    it "supports untagged query" do
      collection.with_params(q: "test")
      expect(collection.filters).to eq("search" => "test")
    end

    it "supports multiple untagged queries" do
      collection.with_params(q: "active status")
      expect(collection.filters).to eq("search" => "active status")
    end

    it "supports quoted untagged queries" do
      collection.with_params(q: '"active status"')
      expect(collection.filters).to eq("search" => '"active status"')
    end
  end

  describe "booleans" do
    it "supports tagged queries" do
      collection.with_params(q: "active:true")
      expect(collection.filters).to eq("active" => true)
    end

    it "supports quoted tag values" do
      collection.with_params(q: 'active:"true"')
      expect(collection.filters).to eq("active" => true)
    end

    it "supports false for booleans" do
      collection.with_params(q: "active:false")
      expect(collection.filters).to eq("active" => false)
    end
  end

  describe "dates" do
    it "supports tagged dates" do
      collection.with_params(q: "created_at: 1970-01-01")
      expect(collection.filters).to eq("created_at" => Date.parse("1970-01-01"))
    end

    it "supports quoted dates" do
      collection.with_params(q: 'created_at:"1970-01-01"')
      expect(collection.filters).to eq("created_at" => Date.parse("1970-01-01"))
    end

    it "supports date ranges" do
      collection.with_params(q: "created_at:1970-01-01..")
      expect(collection.filters).to eq("created_at" => Date.parse("1970-01-01")..)
    end
  end

  describe "enums" do
    it "supports single values for enums" do
      collection.with_params(q: "category:report")
      expect(collection.filters).to eq("category" => ["report"])
    end

    it "supports arrays for enums" do
      collection.with_params(q: "category: [article, report]")
      expect(collection.filters).to eq("category" => %w[article report])
    end

    it "supports arrays with quoted values" do
      collection.with_params(q: 'category:["article", "report", "space separated", "escapes]"]')
      expect(collection.filters).to eq("category" => ["article", "report", "space separated", "escapes]"])
    end
  end

  describe "associations" do
    it "supports complex keys" do
      collection.with_params(q: "parent.name:test")
      expect(collection.filters).to eq("parent.name" => "test")
    end

    it "ignores unknown keys" do
      collection.with_params(q: "boom.name:test")
      expect(collection.filters).not_to include("boom.name" => "test")
    end

    it "adds unknown keys to errors" do
      collection.with_params(q: "boom.name:test")
      expect(collection.errors).to include(:"boom.name")
    end

    it "supports complex keys with ids" do
      collection.with_params(q: "parent.id:15")
      expect(collection.filters).to eq("parent.id" => [15])
    end
  end

  describe "#examples_for" do
    it "supports basic types" do
      create_list(:resource, 1, active: true)
      expect(collection.apply(Resource).examples_for("active")).to eq([true, false])
    end

    it "limits example count" do
      create_list(:resource, 11) # rubocop:disable FactoryBot/ExcessiveCreateList
      expect(collection.apply(Resource).examples_for("index")).to eq((1..10).to_a)
    end

    it "deduplicates values" do
      create_list(:resource, 5, index: 1)
      expect(collection.apply(Resource).examples_for("index")).to eq([1])
    end

    it "supports complex keys" do
      create_list(:child, 1)
      expect(collection.apply(Nested::Child).examples_for("parent.name")).to eq(["Parent 1"])
    end
  end
end
