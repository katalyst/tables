# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Type::String do
  def new_collection(params = {}, &block)
    Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query

      instance_eval(&block)
    end.with_params(params)
  end

  def filter(collection, scope = Resource.all, key: "name")
    attribute = collection.instance_variable_get(:@attributes)[key]
    attribute.type.filter(scope, attribute)
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

      expect(filter(collection, Nested::Child.all, key: "parent.name").to_sql).to eq(
        Nested::Child.joins(:parent)
                     .where(Arel.sql(
                              "\"parents\".\"name\" LIKE ?", "%test%"
                            ))
                     .to_sql,
      )
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

  describe "#examples_for" do
    let(:collection) { new_collection { attribute :name, :string }.apply(Resource) }

    it "returns values from database" do
      create_list(:resource, 2)
      expect(collection.examples_for(:name).map(&:value)).to contain_exactly("Resource 1", "Resource 2")
    end

    it "removes duplicates" do
      create_list(:resource, 2, name: "duplicate")
      expect(collection.examples_for(:name).map(&:value)).to contain_exactly("duplicate")
    end

    context "with a belongs_to association" do
      let(:collection) { new_collection { attribute :"parent.name", :string }.apply(Nested::Child) }

      it "returns values from parent" do
        create_list(:child, 2)
        expect(collection.examples_for(:"parent.name").map(&:value)).to contain_exactly("Parent 1", "Parent 2")
      end

      it "does not return unrelated parents" do
        create(:parent)
        create(:child)
        expect(collection.examples_for(:"parent.name").map(&:value)).to contain_exactly("Parent 2")
      end
    end
  end
end
