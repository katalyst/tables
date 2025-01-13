# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Type::String do
  def new_collection(params = {}, &block)
    Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query

      instance_eval(&block)
    end.with_params(params)
  end

  def filter(collection, scope = Resource.all)
    collection.apply(scope).items
  end

  describe "#filter" do
    it "does not run by default" do
      collection = new_collection do
        attribute :name, :string
      end

      expect(filter(collection).to_sql).to eq(Resource.all.to_sql)
    end

    it "supports string matching" do
      collection = new_collection(name: "aaron") do
        attribute :name, :string
      end

      expect(filter(collection).to_sql).to eq(
        Resource.where(Arel.sql("\"resources\".\"name\" LIKE ?",
                                "%aaron%")).to_sql,
      )
    end

    it "supports string equality" do
      collection = new_collection(name: "aaron") do
        attribute :name, :string, exact: true
      end

      expect(filter(collection).to_sql).to eq(Resource.where(name: "aaron").to_sql)
    end

    it "supports scopes" do
      collection = new_collection(name: "aaron") do
        attribute :name, :string, scope: :custom
      end

      allow(Resource).to receive(:custom) { |v| Resource.where(custom: v) }

      expect(filter(collection).to_sql).to eq(Resource.where(custom: "aaron").to_sql)
    end

    it "supports string match escaping" do
      collection = new_collection(name: "a_b") do
        attribute :name, :string
      end

      expect(filter(collection).to_sql).to eq(
        Resource.where(Arel.sql("\"resources\".\"name\" LIKE ?",
                                "%a\\_b%")).to_sql,
      )
    end

    it "supports complex key matching on strings" do
      collection = new_collection("parent.name": "test") do
        attribute :"parent.name", :string
      end

      expect(filter(collection, Nested::Child.all).to_sql).to eq(<<~SQL.squish)
        SELECT "nested_children".*
        FROM "nested_children"
        INNER JOIN "parents" "parent" ON "parent"."id" = "nested_children"."parent_id"
        WHERE "parent"."name" LIKE '%test%'
      SQL
    end

    it "supports joining on table aliases" do
      collection = new_collection("friends.name": "test") do
        attribute :"friends.name", :string
      end

      expect(filter(collection, Person.all).to_sql).to eq(<<~SQL.squish)
        SELECT "people".*
        FROM "people"
        INNER JOIN "people_friends" ON "people_friends"."person_id" = "people"."id"
        INNER JOIN "people" "friends" ON "friends"."id" = "people_friends"."friend_id"
        WHERE "friends"."name" LIKE '%test%'
      SQL
    end
  end

  describe "#cast" do
    subject(:type) { described_class.new }

    it { expect(type.cast(nil)).to be_nil }
    it { expect(type.cast("test")).to eq "test" }
    it { expect(type.cast([])).to eq "[]" }
  end

  describe "#serialize" do
    subject(:type) { described_class.new }

    it { expect(type.serialize(nil)).to be_nil }
    it { expect(type.serialize("test")).to eq "test" }
    it { expect(type.serialize([])).to eq [] }
    it { expect(type.serialize(["test"])).to eq ["test"] }
  end

  describe "#deserialize" do
    subject(:type) { described_class.new }

    it { expect(type.deserialize(nil)).to be_nil }
    it { expect(type.deserialize("test")).to eq "test" }
    it { expect(type.deserialize([])).to eq "[]" }
  end

  describe "#suggestions" do
    let(:collection) { new_collection { attribute :name, :string }.with_params(params).apply(Resource) }
    let(:params) { { q: "name:", p: 5 } }

    it "returns values from database" do
      create_list(:resource, 2)
      expect(collection.suggestions.map(&:value)).to contain_exactly("Resource 1", "Resource 2")
    end

    it "removes duplicates" do
      create_list(:resource, 2, name: "duplicate")
      expect(collection.suggestions.map(&:value)).to contain_exactly("duplicate")
    end

    context "when cursor is on a partial value" do
      let(:params) { { q: "name:pa", p: 7 } }

      it "returns value suggestions" do
        create(:resource, name: "Paul")
        create(:resource, name: "George")
        expect(collection.suggestions.map(&:value)).to contain_exactly("Paul")
      end
    end

    context "with a belongs_to association" do
      let(:collection) { new_collection { attribute :"parent.name", :string }.with_params(params).apply(Nested::Child) }
      let(:params) { { q: "parent.name:", p: 12 } }

      it "returns values from parent" do
        create_list(:child, 2)
        expect(collection.suggestions.map(&:value)).to contain_exactly("Parent 1", "Parent 2")
      end

      it "does not return unrelated parents" do
        create(:parent)
        create(:child)
        expect(collection.suggestions.map(&:value)).to contain_exactly("Parent 2")
      end
    end

    context "with a has_and_belongs_to_many association" do
      let(:collection) { new_collection { attribute :"friends.name", :string }.with_params(params).apply(Person) }
      let(:params) { { q: "friends.name:", p: 13 } }

      it "returns values from friends" do
        amy  = create(:person, name: "Amy")
        beth = create(:person, name: "Beth")
        amy.friends << beth

        expect(collection.suggestions.map(&:value)).to contain_exactly("Beth")
      end
    end
  end
end
