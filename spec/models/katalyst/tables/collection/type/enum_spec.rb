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

  describe "#cast" do
    subject(:type) { described_class.new }

    it { expect(type.cast(nil)).to be_nil }
    it { expect(type.cast("article")).to eq "article" }
    it { expect(type.cast([])).to eq [] }
    it { expect(type.cast(["article"])).to eq ["article"] }
  end

  describe "#serialize" do
    subject(:type) { described_class.new }

    it { expect(type.serialize(nil)).to be_nil }
    it { expect(type.serialize("article")).to eq "article" }
    it { expect(type.serialize([])).to eq [] }
    it { expect(type.serialize(["article"])).to eq ["article"] }
  end

  describe "#deserialize" do
    subject(:type) { described_class.new }

    it { expect(type.deserialize(nil)).to be_nil }
    it { expect(type.deserialize("article")).to eq "article" }
    it { expect(type.deserialize([])).to eq [] }
    it { expect(type.deserialize(["article"])).to eq ["article"] }
  end

  describe "#examples_for" do
    let(:collection) { new_collection(params) { attribute :category, :enum }.apply(Resource) }
    let(:params) { {} }

    it "returns all enum values" do
      expect(collection.examples_for(:category)).to contain_exactly("article", "documentation", "report")
    end

    context "when a partial value is provided" do
      let(:params) { { q: "category: a" } }

      it "filters the available values" do
        expect(collection.examples_for(:category)).to contain_exactly("article", "documentation")
      end
    end
  end
end
