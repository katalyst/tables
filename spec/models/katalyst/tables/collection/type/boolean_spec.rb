# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Type::Boolean do
  def new_collection(params = {}, &block)
    Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query

      instance_eval(&block)
    end.with_params(params)
  end

  def filter(collection, scope = Resource.all, key: "active")
    attribute = collection.instance_variable_get(:@attributes)[key]
    attribute.type.filter(scope, attribute)
  end

  describe "#filter" do
    it "does not run by default" do
      collection = new_collection do
        attribute :active, :boolean
      end

      expect(filter(collection).to_sql).to eq(Resource.all.to_sql)
    end

    it "supports true" do
      collection = new_collection(active: true) do
        attribute :active, :boolean
      end

      expect(filter(collection).to_sql).to eq(Resource.where(active: true).to_sql)
    end

    it "supports false" do
      collection = new_collection(active: false) do
        attribute :active, :boolean
      end

      expect(filter(collection).to_sql).to eq(Resource.where(active: false).to_sql)
    end

    it "supports default true" do
      collection = new_collection do
        attribute :active, :boolean, default: true
      end

      expect(filter(collection).to_sql).to eq(Resource.where(active: true).to_sql)
    end

    it "supports default false" do
      collection = new_collection do
        attribute :active, :boolean, default: false
      end

      expect(filter(collection).to_sql).to eq(Resource.where(active: false).to_sql)
    end

    it "supports scopes" do
      collection = new_collection(updated: true) do
        attribute :updated, :boolean, scope: :updated
      end

      expect(filter(collection, key: "updated").to_sql).to eq(Resource.where("created_at != updated_at").to_sql)
    end

    it "supports complex keys" do
      collection = new_collection("parent.active": true) do
        attribute :"parent.active", :boolean
      end

      expect(filter(collection, Nested::Child.all, key: "parent.active").to_sql)
        .to eq(Nested::Child.joins(:parent).merge(Parent.where(active: true)).to_sql)
    end

    it "supports complex keys with scope" do
      collection = new_collection("parent.updated": true) do
        attribute :"parent.updated", :boolean, scope: :updated
      end

      expect(filter(collection, Nested::Child.all, key: "parent.updated").to_sql)
        .to eq(Nested::Child.joins(:parent).merge(Parent.where.not(updated_at: nil)).to_sql)
    end
  end
end
