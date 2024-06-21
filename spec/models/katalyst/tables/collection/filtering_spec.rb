# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Filtering do
  subject(:collection) do
    Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query

      attribute :id, :integer, multiple: true
      attribute :search, :search, scope: :table_search
      attribute :name, :string
      attribute :active, :boolean
      attribute :updated, :boolean, scope: :updated
      attribute :created_at, :date
      attribute :category, :enum
      attribute :"parent.name", :string
      attribute :"parent.active", :boolean
      attribute :"parent.updated", :boolean, scope: :updated
      attribute :"parent.id", :integer, multiple: true
      attribute :"parent.role", :enum
    end
  end

  it "supports search" do
    scope = collection.with_params(q: "test").apply(Resource.all)
    expect(scope.items.to_sql).to eq(Resource.table_search("test").to_sql)
  end

  it "supports booleans" do
    scope = collection.with_params(q: "active:true").apply(Resource.all)
    expect(scope.items.to_sql).to eq(Resource.where(active: true).to_sql)
  end

  it "supports dates" do
    scope = collection.with_params(q: "created_at:1970-01-01..2200-01-01").apply(Resource.all)
    expect(scope.items.to_sql)
      .to eq(Resource.where(created_at: Date.parse("1970-01-01")..Date.parse("2200-01-01")).to_sql)
  end

  it "supports strings" do
    scope = collection.with_params(q: "name:Aaron").apply(Nested::Child.all)
    expect(scope.items.to_sql).to eq(
      Nested::Child.where(Arel.sql("\"nested_children\".\"name\" LIKE ?",
                                   "%Aaron%")).to_sql,
    )
  end

  describe "multi value" do
    it "supports single values for enums" do
      scope = collection.with_params(q: "category:report").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.where(category: :report).to_sql)
    end

    it "supports multiple values for enums" do
      scope = collection.with_params(q: "category: [article, report]").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.where(category: %i[article report]).to_sql)
    end

    it "supports invalid enum values" do
      scope = collection.with_params(q: "category: [bad]").apply(Resource.all)
      expect(scope.items.to_sql).to eq(Resource.where(category: nil).to_sql)
    end

    it "supports complex key matching on enums" do
      scope = collection.with_params(q: "parent.role:teacher").apply(Nested::Child.all)
      expect(scope.items.to_sql).to eq(
        Nested::Child.joins(:parent)
                     .merge(Parent.where(role: :teacher))
                     .to_sql,
      )
    end

    it "supports complex key matching on id arrays" do
      scope = collection.with_params(q: "parent.id:[15, 10]").apply(Nested::Child.all)
      expect(scope.items.to_sql).to eq(
        Nested::Child.joins(:parent)
                     .merge(Parent.where(id: [15, 10]))
                     .to_sql,
      )
    end
  end

  it "supports complex key matching on ids" do
    scope = collection.with_params(q: "parent.id:15").apply(Nested::Child.all)
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
