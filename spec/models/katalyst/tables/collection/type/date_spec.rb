# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Type::Date do
  let(:type) { described_class.new }

  def new_collection(params = {}, &block)
    Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query

      instance_eval(&block)
    end.with_params(params)
  end

  def filter(collection, scope = Resource.all, key: "created_at")
    attribute = collection.instance_variable_get(:@attributes)[key]
    attribute.type.filter(scope, attribute)
  end

  describe "#cast" do
    context "when assigning value to object attribute" do
      it "translates user input Date string to date" do
        expect(type.cast("1970-01-01")).to eq(Date.parse("1970-01-01"))
      end

      it "translates user input lower bound to range" do
        expect(type.cast(">1970-01-01")).to eq(Date.parse("1970-01-01")..)
      end

      it "translates user input upper bound to range" do
        expect(type.cast("<1970-01-01")).to eq(..Date.parse("1970-01-01"))
      end

      it "translates user input bounds to range" do
        expect(type.cast("1970-01-01..2200-01-01"))
          .to eq(Date.parse("1970-01-01")..Date.parse("2200-01-01"))
      end

      it "is idempotent for dates" do
        expect(type.cast(Date.parse("1970-01-01"))).to eq(Date.parse("1970-01-01"))
      end

      it "is idempotent for ranges" do
        expect(type.cast(Date.parse("1970-01-01")..)).to eq(Date.parse("1970-01-01")..)
      end
    end
  end

  describe "#serialize" do
    context "when saving to db" do
      it "translates Date to user input" do
        expect(type.serialize(Date.parse("1970-01-01"))).to eq("1970-01-01")
      end

      it "translates lower bound range to user input" do
        expect(type.serialize(Date.parse("1970-01-01")..)).to eq(">1970-01-01")
      end

      it "translates upper bound range to user input" do
        expect(type.serialize(..Date.parse("1970-01-01"))).to eq("<1970-01-01")
      end

      it "translates bounds range to user input" do
        expect(type.serialize(Date.parse("1970-01-01")..Date.parse("2200-01-01")))
          .to eq("1970-01-01..2200-01-01")
      end
    end
  end

  describe "#filter" do
    it "does not run by default" do
      collection = new_collection do
        attribute :created_at, :date
      end

      expect(filter(collection).to_sql).to eq(Resource.all.to_sql)
    end

    it "supports tagged dates" do
      collection = new_collection(created_at: "1970-01-01") do
        attribute :created_at, :date
      end

      expect(filter(collection).to_sql).to eq(Resource.where(created_at: Date.parse("1970-01-01")).to_sql)
    end

    it "supports date range" do
      collection = new_collection(created_at: "1970-01-01..2200-01-01") do
        attribute :created_at, :date
      end

      expect(filter(collection).to_sql)
        .to eq(Resource.where(created_at: Date.parse("1970-01-01")..Date.parse("2200-01-01")).to_sql)
    end

    it "supports date ranges with lower bound" do
      collection = new_collection(created_at: ">1970-01-01") do
        attribute :created_at, :date
      end

      expect(filter(collection).to_sql).to eq(Resource.where(created_at: Date.parse("1970-01-01")..).to_sql)
    end

    it "supports date ranges with upper bound" do
      collection = new_collection(created_at: "<2200-01-01") do
        attribute :created_at, :date
      end

      expect(filter(collection).to_sql).to eq(Resource.where(created_at: ..Date.parse("2200-01-01")).to_sql)
    end

    it "supports unparseable dates" do
      collection = new_collection(created_at: "2020") do
        attribute :created_at, :date
      end

      expect(filter(collection).to_sql).to eq(Resource.none.to_sql)
    end

    it "supports invalid dates" do
      collection = new_collection(created_at: "0000-00-00") do
        attribute :created_at, :date
      end

      expect(filter(collection).to_sql).to eq(Resource.none.to_sql)
    end
  end
end
