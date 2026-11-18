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
        .to eq(<<~SQL.squish)
          SELECT "nested_children".*
          FROM "nested_children"
          INNER JOIN "parents" AS "parent" ON "parent"."id" = "nested_children"."parent_id"
          WHERE "parent"."role" = 1
        SQL
    end
  end

  # Unknown values cast to nil in the enum mapping, which filters on IS NULL.
  # A value that cannot exist should match nothing.
  describe "#filter with NUL bytes" do
    it "matches nothing for values containing NUL bytes" do
      collection = new_collection(category: ["\0"]) do
        attribute :category, :enum
      end

      expect(filter(collection).to_sql).to eq(Resource.none.to_sql)
    end

    it "ignores values containing NUL bytes alongside valid values" do
      collection = new_collection(category: ["article", "\0"]) do
        attribute :category, :enum
      end

      expect(filter(collection).to_sql).to eq(Resource.where(category: %w[article]).to_sql)
    end
  end

  describe "#filter with unknown values" do
    it "matches nothing for unknown values", pending: "unknown values filter on category IS NULL" do
      collection = new_collection(category: ["bogus"]) do
        attribute :category, :enum
      end

      expect(filter(collection).to_sql).to eq(Resource.none.to_sql)
    end

    it "matches nothing for unknown query values", pending: "unknown values filter on category IS NULL" do
      collection = new_collection(q: "category:bogus") do
        attribute :category, :enum
      end

      expect(filter(collection).to_sql).to eq(Resource.none.to_sql)
    end

    it "matches known values alongside unknown values" do
      article = create(:resource, category: :article)
      create(:resource, category: :report)

      collection = new_collection(category: %w[article bogus]) do
        attribute :category, :enum
      end

      expect(filter(collection).to_a).to contain_exactly(article)
    end
  end

  describe "#cast" do
    subject(:type) { described_class.new }

    it { expect(type.cast(nil)).to eq [] }
    it { expect(type.cast("article")).to eq ["article"] }
    it { expect(type.cast([])).to eq [] }
    it { expect(type.cast(["article"])).to eq ["article"] }
    it { expect(type.cast([:article])).to eq ["article"] }
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

    it { expect(type.deserialize(nil)).to eq [] }
    it { expect(type.deserialize("article")).to eq ["article"] }
    it { expect(type.deserialize([])).to eq [] }
    it { expect(type.deserialize(["article"])).to eq ["article"] }
  end

  describe "#suggestions" do
    let(:collection) { new_collection(params) { attribute :category, :enum }.apply(Resource) }
    let(:params) { { q: "category:", p: 9 } }

    it "returns all enum values" do
      expect(collection.suggestions.map(&:value)).to contain_exactly("article", "documentation", "report")
    end

    context "when focus is a partial value" do
      let(:params) { { q: "category: a", p: 11 } }

      it "filters the available values" do
        expect(collection.suggestions.map(&:value)).to contain_exactly("article", "documentation")
      end
    end

    context "when focus is an incomplete array" do
      let(:params) { { q: "category: [article,", p: 19 } }

      it "filters the available values" do
        expect(collection.suggestions.map(&:value))
          .to contain_exactly("article", "documentation", "report")
      end
    end

    context "when cursor is inside an array value" do
      let(:params) { { q: "category: [article, re", p: 22 } }

      it "filters value suggestions" do
        expect(collection.suggestions).to contain_exactly(have_attributes(type: :constant_value, value: "report"))
      end
    end
  end
end
