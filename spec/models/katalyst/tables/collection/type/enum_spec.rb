# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Type::Enum do
  def new_collection(params = {}, &block)
    Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query

      instance_eval(&block)
    end.with_params(params)
  end

  def filter(collection, scope = Resource.all, key: "category")
    attribute = collection.instance_variable_get(:@attributes)[key]
    attribute.type.filter(scope, attribute)
  end

  describe "#filter" do
    it "does not run by default" do
      collection = new_collection do
        attribute :category, :enum
      end

      expect(filter(collection).to_sql).to eq(Resource.all.to_sql)
    end

    it "supports enum equality" do
      collection = new_collection(category: ["article"]) do
        attribute :category, :enum
      end

      expect(filter(collection).to_sql).to eq(Resource.where(category: :article).to_sql)
    end

    it "supports enum inclusion" do
      collection = new_collection(category: %w[article documentation]) do
        attribute :category, :enum
      end

      expect(filter(collection).to_sql).to eq(Resource.where(category: %i[article documentation]).to_sql)
    end

    it "supports scopes" do
      collection = new_collection(category: ["article"]) do
        attribute :category, :enum, scope: :custom
      end

      allow(Resource).to receive(:custom) { |v| Resource.where(custom: v) }

      expect(filter(collection).to_sql).to eq(Resource.where(custom: "article").to_sql)
    end

    it "supports complex key enums" do
      collection = new_collection("parent.role": ["teacher"]) do
        attribute :"parent.role", :enum
      end

      expect(filter(collection, Nested::Child.all, key: "parent.role").to_sql)
        .to eq(Nested::Child.joins(:parent).merge(Parent.where(role: :teacher)).to_sql)
    end
  end
end
