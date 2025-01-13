# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Type::Float do
  def new_collection(params = {}, &block)
    Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query

      instance_eval(&block)
    end.with_params(params)
  end

  def filter(collection, scope = Resource.all, key: "value")
    attribute = collection.instance_variable_get(:@attributes)[key]
    attribute.type.filter(scope, attribute)
  end

  describe "#filter" do
    it "does not run by default" do
      collection = new_collection do
        attribute :value, :float
      end

      expect(filter(collection).to_sql).to eq(Resource.all.to_sql)
    end

    it "supports single values" do
      collection = new_collection(value: 1.0) do
        attribute :value, :float
      end

      expect(filter(collection).to_sql).to eq(Resource.where(value: 1.0).to_sql)
    end

    it "supports multi-values" do
      collection = new_collection(value: [1.0, 2.0]) do
        attribute :value, :float, multiple: true
      end

      expect(filter(collection).to_sql).to eq(Resource.where(value: [1.0, 2.0]).to_sql)
    end

    it "supports ranges" do
      collection = new_collection(value: "0.0..") do
        attribute :value, :float
      end

      expect(filter(collection).to_sql).to eq(Resource.where(value: 0.0..).to_sql)
    end

    it "supports unset" do
      collection = new_collection(value: nil) do
        attribute :value, :integer
      end

      expect(filter(collection).to_sql).to eq(Resource.all.to_sql)
    end

    it "supports invalid" do
      collection = new_collection(value: "invalid") do
        attribute :value, :integer
      end

      # note: this defined by Ruby behaviour: "invalid".to_f => 0
      expect(filter(collection).to_sql).to eq(Resource.where(value: 0).to_sql)
    end

    it "supports defaults" do
      collection = new_collection do
        attribute :value, :float, default: 1.0
      end

      expect(filter(collection).to_sql).to eq(Resource.where(value: 1.0).to_sql)
    end

    it "supports scopes" do
      collection = new_collection(value: 1.0) do
        attribute :value, :float, scope: :custom
      end
      allow(Resource).to receive(:custom) { |v| Resource.where(custom: v) }

      expect(filter(collection).to_sql).to eq(Resource.where(custom: 1.0).to_sql)
    end

    it "supports complex keys" do
      collection = new_collection("parent.id": true) do
        attribute :"parent.id", :float
      end

      expect(filter(collection, Nested::Child.all, key: "parent.id").to_sql)
        .to eq(<<~SQL.squish)
          SELECT "nested_children".*
          FROM "nested_children"
          INNER JOIN "parents" "parent" ON "parent"."id" = "nested_children"."parent_id"
          WHERE "parent"."id" = 1
        SQL
    end
  end

  describe "#cast" do
    subject(:type) { described_class.new }

    it { expect(type.cast(nil)).to be_nil }
    it { expect(type.cast(0.0)).to eq 0.0 }
    it { expect(type.cast("0.0")).to eq 0.0 }
    it { expect(type.cast([])).to be_nil }
    it { expect(type.cast("..0.0")).to eq(..0.0) }
    it { expect(type.cast("0.0..")).to eq(0.0..) }
    it { expect(type.cast("0.0..1.0")).to eq(0.0..1.0) }
    it { expect(type.cast(0.0..1.0)).to eq(0.0..1.0) }

    context "when multiple: true" do
      subject(:type) { described_class.new(multiple: true) }

      it { expect(type.cast(nil)).to be_nil }
      it { expect(type.cast(0.0)).to eq [0.0] }
      it { expect(type.cast("0.0")).to eq [0.0] }
      it { expect(type.cast([])).to eq [] }
      it { expect(type.cast(["0.0"])).to eq [0.0] }
      it { expect(type.cast("..0.0")).to eq(..0.0) }
      it { expect(type.cast(["..0.0"])).to eq([]) }
    end
  end

  describe "#serialize" do
    subject(:type) { described_class.new }

    it { expect(type.serialize(nil)).to be_nil }
    it { expect(type.serialize(0.0)).to eq 0.0 }
    it { expect(type.serialize("0.0")).to eq 0.0 }
    it { expect(type.serialize([])).to be_nil }

    context "when multiple: true" do
      subject(:type) { described_class.new(multiple: true) }

      it { expect(type.serialize(nil)).to be_nil }
      it { expect(type.serialize(0.0)).to eq 0.0 }
      it { expect(type.serialize("0.0")).to eq 0.0 }
      it { expect(type.serialize([])).to eq [] }
      it { expect(type.serialize(["0.0"])).to eq [0.0] }
    end
  end

  describe "#to_param" do
    subject(:type) { described_class.new }

    it { expect(type.to_param(nil)).to be_nil }
    it { expect(type.to_param(0.0)).to eq 0.0 }
    it { expect(type.to_param("0.0")).to eq 0.0 }
    it { expect(type.to_param([])).to be_nil }
    it { expect(type.to_param("")).to be_nil }
    it { expect(type.to_param(0.0..)).to eq "0.0.." }

    context "when multiple: true" do
      subject(:type) { described_class.new(multiple: true) }

      it { expect(type.to_param(nil)).to be_nil }
      it { expect(type.to_param(0.0)).to eq 0.0 }
      it { expect(type.to_param([])).to eq "[]" }
      it { expect(type.to_param([0.0])).to eq "[0.0]" }
    end
  end

  describe "#deserialize" do
    subject(:type) { described_class.new }

    it { expect(type.deserialize(nil)).to be_nil }
    it { expect(type.deserialize(0.0)).to eq 0.0 }
    it { expect(type.deserialize("0.0")).to eq 0.0 }

    context "when multiple: true" do
      subject(:type) { described_class.new(multiple: true) }

      it { expect(type.deserialize(nil)).to eq [] }
      it { expect(type.deserialize(0.0)).to eq [0.0] }
      it { expect(type.deserialize("0.0")).to eq [0.0] }
      it { expect(type.deserialize([])).to eq [] }
      it { expect(type.deserialize(["0.0"])).to eq [0.0] }
    end
  end
end
