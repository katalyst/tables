# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Filtering do
  subject(:collection) do
    Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query

      config.search_scope = :table_search

      attribute :id, default: -> { [] }
      attribute :search
      attribute :name, :string
      attribute :active, :boolean # exists
      attribute :updated, :boolean # derived
      attribute :created_at, :date_range
      attribute :category, default: -> { [] }
      attribute :"parent.name", :string
      attribute :"parent.active", :boolean
      attribute :"parent.updated", :boolean
      attribute :"parent.id", default: -> { [] }
      attribute :"parent.role", default: -> { [] }
    end
  end

  describe "search" do
    it "supports empty query" do
      scope = collection.with_params(query: "").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.all.to_sql)
    end

    it "supports untagged query" do
      scope = collection.with_params(query: "test").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.table_search("test").to_sql)
    end

    it "supports multiple untagged queries" do
      scope = collection.with_params(query: "active status").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.table_search("active status").to_sql)
    end

    it "supports quoted untagged queries" do
      scope = collection.with_params(query: '"active status"').apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.table_search('"active status"').to_sql)
    end
  end

  describe "booleans" do
    it "supports tagged booleans" do
      scope = collection.with_params(query: "active:true").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.where(active: true).to_sql)
    end

    it "supports tagged booleans with false" do
      scope = collection.with_params(query: "active:false").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.where(active: false).to_sql)
    end

    it "supports derived value booleans" do
      scope = collection.with_params(query: "updated:true").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.where("created_at != updated_at").to_sql)
    end

    it "supports complex key matching on booleans" do
      scope = collection.with_params(query: "parent.active:true").apply(Nested::Child.all)
      expect(scope.items.to_sql).to eq(
        Nested::Child.joins(:parent)
                     .merge(Parent.where(active: true))
                     .to_sql,
      )
    end

    it "supports complex key matching on synthetic booleans" do
      scope = collection.with_params(query: "parent.updated:true").apply(Nested::Child.all)
      expect(scope.items.to_sql).to eq(
        Nested::Child.joins(:parent)
                     .merge(Parent.where.not(updated_at: nil))
                     .to_sql,
      )
    end
  end

  describe "dates" do
    it "supports tagged dates" do
      scope = collection.with_params(query: "created_at:1970-01-01").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.where(created_at: Date.parse("1970-01-01")).to_sql)
    end

    it "supports date range" do
      scope = collection.with_params(query: "created_at:1970-01-01..2200-01-01").apply(Resource.all)
      expect(scope.items.to_sql)
        .to eq(Resource.where(created_at: Date.parse("1970-01-01")..Date.parse("2200-01-01")).to_sql)
    end

    it "supports date ranges with lower bound" do
      scope = collection.with_params(query: "created_at:>1970-01-01").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.where(created_at: Date.parse("1970-01-01")..).to_sql)
    end

    it "supports date ranges with upper bound" do
      scope = collection.with_params(query: "created_at:<2200-01-01").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.where(created_at: ..Date.parse("2200-01-01")).to_sql)
    end
  end

  describe "multi value" do
    it "supports single values for enums" do
      scope = collection.with_params(query: "category:report").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.where(category: :report).to_sql)
    end

    it "supports multiple values for enums" do
      scope = collection.with_params(query: "category: [article, report]").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.where(category: %i[article report]).to_sql)
    end

    it "supports invalid enum values" do
      scope = collection.with_params(query: "category: [bad]").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.where(category: nil).to_sql)
    end

    it "supports complex key matching on enums" do
      scope = collection.with_params(query: "parent.role:teacher").apply(Nested::Child.all)
      expect(scope.items.to_sql).to eq(
        Nested::Child.joins(:parent)
                     .merge(Parent.where(role: :teacher))
                     .to_sql,
      )
    end

    it "supports complex key matching on id arrays" do
      scope = collection.with_params(query: "parent.id:[15, 10]").apply(Nested::Child.all)
      expect(scope.items.to_sql).to eq(
        Nested::Child.joins(:parent)
                     .merge(Parent.where(id: [15, 10]))
                     .to_sql,
      )
    end
  end

  describe "strings" do
    it "supports string matching" do
      scope = collection.with_params(query: "name:Aaron").apply(Nested::Child.all)
      expect(scope.items.to_sql).to eq(
        Nested::Child.where(Arel.sql("\"nested_children\".\"name\" LIKE ?",
                                     "%Aaron%")).to_sql,
      )
    end

    it "supports string match escaping" do
      scope = collection.with_params(query: "name:a_b").apply(Nested::Child.all)
      expect(scope.items.to_sql).to eq(
        Nested::Child.where(Arel.sql("\"nested_children\".\"name\" LIKE ?",
                                     "%a\\_b%")).to_sql,
      )
    end

    it "supports complex key matching on strings" do
      scope = collection.with_params(query: "parent.name:test").apply(Nested::Child.all)
      expect(scope.items.to_sql).to eq(
        Nested::Child.joins(:parent)
                     .where(Arel.sql("\"parents\".\"name\" LIKE ?", "%test%"))
                     .to_sql,
      )
    end
  end

  it "supports complex key matching on ids" do
    scope = collection.with_params(query: "parent.id:15").apply(Nested::Child.all)
    expect(scope.items.to_sql).to eq(
      Nested::Child.joins(:parent)
                   .where(Arel.sql("\"parents\".\"id\" = ?", 15))
                   .to_sql,
    )
  end

  it "doesn't interfere with id filters (selection)" do
    scope = collection.with_params(id: [1, 2, 3]).apply(Resource.all)
    expect(scope.items.to_sql).to eq(Resource.where(id: [1, 2, 3]).to_sql)
  end
end
