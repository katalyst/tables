# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Query do
  subject(:collection) do
    Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query

      config.search_scope = :table_search

      attribute :id, default: -> { [] }
      attribute :search
      attribute :name, :string
      attribute :active, :boolean
      attribute :category, default: -> { [] }
      attribute :"parent.name", :string
      attribute :"parent.id", default: -> { [] }
    end.new
  end

  it "supports empty query" do
    collection.with_params(query: "")
    expect(collection.filters).to eq({})
  end

  it "drops unsupported tags" do
    collection.with_params(query: "unknown:true")
    expect(collection.filters).to eq({})
  end

  describe "search" do
    it "supports untagged query" do
      collection.with_params(query: "test")
      expect(collection.filters).to eq("search" => "test")
    end

    it "supports multiple untagged queries" do
      collection.with_params(query: "active status")
      expect(collection.filters).to eq("search" => "active status")
    end

    it "supports quoted untagged queries" do
      collection.with_params(query: '"active status"')
      expect(collection.filters).to eq("search" => '"active status"')
    end
  end

  describe "booleans" do
    it "supports tagged queries" do
      collection.with_params(query: "active:true")
      expect(collection.filters).to eq("active" => true)
    end

    it "supports quoted tag values" do
      collection.with_params(query: 'active:"true"')
      expect(collection.filters).to eq("active" => true)
    end

    it "supports false for booleans" do
      collection.with_params(query: 'active:false')
      expect(collection.filters).to eq("active" => false)
    end
  end

  describe "enums" do
    it "supports single values for enums" do
      collection.with_params(query: "category:report")
      expect(collection.filters).to eq("category" => ["report"])
    end

    it "supports arrays for enums" do
      collection.with_params(query: "category: [article, report]")
      expect(collection.filters).to eq("category" => %w[article report])
    end

    it "supports arrays with quoted values" do
      collection.with_params(query: 'category:["article", "report", "space separated", "escapes]"]')
      expect(collection.filters).to eq("category" => ["article", "report", "space separated", "escapes]"])
    end
  end

  describe "associations" do
    it "supports complex keys" do
      collection.with_params(query: "parent.name:test")
      expect(collection.filters).to eq("parent.name" => "test")
    end

    it "ignores unknown keys" do
      collection.with_params(query: "boom.name:test")
      expect(collection.filters).not_to include("boom.name" => "test")
    end

    it "supports complex keys with ids" do
      collection.with_params(query: "parent.id:15")
      expect(collection.filters).to eq("parent.id" => ["15"])
    end
  end
end
