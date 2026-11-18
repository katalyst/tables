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
        expect(type.cast("1970-01-01..")).to eq(Date.parse("1970-01-01")..)
      end

      it "translates user input upper bound to range" do
        expect(type.cast("..1970-01-01")).to eq(..Date.parse("1970-01-01"))
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
    it "translates Date to user input" do
      expect(type.serialize(Date.parse("1970-01-01"))).to eq(Date.parse("1970-01-01"))
    end

    it "translates lower bound range to user input" do
      expect(type.serialize(Date.parse("1970-01-01")..)).to eq(Date.parse("1970-01-01")..)
    end

    it "translates upper bound range to user input" do
      expect(type.serialize(..Date.parse("1970-01-01"))).to eq(..Date.parse("1970-01-01"))
    end

    it "translates bounds range to user input" do
      expect(type.serialize(Date.parse("1970-01-01")..Date.parse("2200-01-01")))
        .to eq(Date.parse("1970-01-01")..Date.parse("2200-01-01"))
    end
  end

  describe "#to_param" do
    it "translates Date to user input" do
      expect(type.to_param(Date.parse("1970-01-01"))).to eq("1970-01-01")
    end

    it "translates lower bound range to user input" do
      expect(type.to_param(Date.parse("1970-01-01")..)).to eq("1970-01-01..")
    end

    it "translates upper bound range to user input" do
      expect(type.to_param(..Date.parse("1970-01-01"))).to eq("..1970-01-01")
    end

    it "translates bounds range to user input" do
      expect(type.to_param(Date.parse("1970-01-01")..Date.parse("2200-01-01")))
        .to eq("1970-01-01..2200-01-01")
    end
  end

  describe "#filter" do
    # Fixtures for the date column examples below.
    let(:published_dates) do
      {
        before_start: "2026-10-31",
        first_day:    "2026-11-01",
        last_day:     "2026-11-15",
        after_end:    "2026-11-16",
      }
    end

    it "does not run by default" do
      collection = new_collection do
        attribute :published_on, :date
      end

      expect(filter(collection, key: "published_on").to_sql).to eq(Resource.all.to_sql)
    end

    it "supports tagged dates" do
      collection = new_collection(published_on: "1970-01-01") do
        attribute :published_on, :date
      end

      expect(filter(collection, key: "published_on").to_sql)
        .to eq(Resource.where(published_on: Date.parse("1970-01-01")).to_sql)
    end

    it "supports date range" do
      collection = new_collection(published_on: "1970-01-01..2200-01-01") do
        attribute :published_on, :date
      end

      expect(filter(collection, key: "published_on").to_sql)
        .to eq(Resource.where(published_on: Date.parse("1970-01-01")..Date.parse("2200-01-01")).to_sql)
    end

    it "supports date ranges with lower bound" do
      collection = new_collection(published_on: "1970-01-01..") do
        attribute :published_on, :date
      end

      expect(filter(collection, key: "published_on").to_sql)
        .to eq(Resource.where(published_on: Date.parse("1970-01-01")..).to_sql)
    end

    it "supports date ranges with upper bound" do
      collection = new_collection(published_on: "..2200-01-01") do
        attribute :published_on, :date
      end

      expect(filter(collection, key: "published_on").to_sql)
        .to eq(Resource.where(published_on: ..Date.parse("2200-01-01")).to_sql)
    end

    it "supports unparseable dates" do
      collection = new_collection(published_on: "2020") do
        attribute :published_on, :date
      end

      expect(filter(collection, key: "published_on").to_sql).to eq(Resource.none.to_sql)
    end

    it "supports invalid dates" do
      collection = new_collection(published_on: "0000-00-00") do
        attribute :published_on, :date
      end

      expect(filter(collection, key: "published_on").to_sql).to eq(Resource.none.to_sql)
    end

    # https://github.com/katalyst/tables/issues/169
    context "with a datetime column in Time.zone" do
      around do |example|
        Time.use_zone("Australia/Adelaide") { example.run }
      end

      # Local (Adelaide, UTC+10:30) timestamps either side of each day boundary.
      # Midnight UTC on 1 November is 10:30 local time.
      before do
        {
          before_start:  "2026-10-31 23:59:59",
          start_of_day:  "2026-11-01 00:00:00",
          first_morning: "2026-11-01 09:00:00",
          first_evening: "2026-11-01 20:00:00",
          last_morning:  "2026-11-15 09:00:00",
          last_evening:  "2026-11-15 23:59:59",
          after_end:     "2026-11-16 00:00:00",
        }.each do |name, time|
          create(:resource, name:, created_at: Time.zone.parse(time))
        end
      end

      def matching(value)
        collection = new_collection(created_at: value) do
          attribute :created_at, :date
        end

        filter(collection).order(:created_at).pluck(:name)
      end

      it "matches the whole local day for a single date" do
        expect(matching("2026-11-01")).to eq(%w[start_of_day first_morning first_evening])
      end

      it "starts a lower bound at the start of the local day" do
        expect(matching("2026-11-01..")).to eq(
          %w[start_of_day first_morning first_evening last_morning last_evening after_end],
        )
      end

      it "includes the whole local day for an upper bound" do
        expect(matching("..2026-11-15")).to eq(
          %w[before_start start_of_day first_morning first_evening last_morning last_evening],
        )
      end

      it "includes both whole local days for a bounded range" do
        expect(matching("2026-11-01..2026-11-15")).to eq(
          %w[start_of_day first_morning first_evening last_morning last_evening],
        )
      end
    end

    # Date columns have no time zone: filters compare dates directly, whatever
    # Time.zone is and whichever side of UTC it falls.
    %w[Australia/Adelaide Pacific/Kiritimati Pacific/Pago_Pago].each do |zone|
      context "with a date column when Time.zone is #{zone}" do
        around do |example|
          Time.use_zone(zone) { example.run }
        end

        before do
          published_dates.each do |name, date|
            create(:resource, name:, published_on: Date.parse(date))
          end
        end

        def collection_for(value)
          new_collection(published_on: value) do
            attribute :published_on, :date
          end
        end

        def matching(value)
          filter(collection_for(value), key: "published_on").order(:published_on).pluck(:name)
        end

        it "compares a single date without time conversion" do
          expect(filter(collection_for("2026-11-01"), key: "published_on").to_sql)
            .to eq(Resource.where(published_on: Date.parse("2026-11-01")).to_sql)
        end

        it "compares a bounded range without time conversion" do
          expect(filter(collection_for("2026-11-01..2026-11-15"), key: "published_on").to_sql)
            .to eq(Resource.where(published_on: Date.parse("2026-11-01")..Date.parse("2026-11-15")).to_sql)
        end

        it "matches a single date" do
          expect(matching("2026-11-01")).to eq(%w[first_day])
        end

        it "matches from a lower bound" do
          expect(matching("2026-11-01..")).to eq(%w[first_day last_day after_end])
        end

        it "matches up to and including an upper bound" do
          expect(matching("..2026-11-15")).to eq(%w[before_start first_day last_day])
        end

        it "matches both ends of a bounded range" do
          expect(matching("2026-11-01..2026-11-15")).to eq(%w[first_day last_day])
        end
      end
    end
  end

  describe "#suggestions" do
    let(:collection) { new_collection(params) { attribute :created_at, :date }.apply(Resource) }
    let(:params) { { q: "created_at:", p: 11 } }

    before { create_list(:resource, 2) }

    it "returns date suggestions based on current date" do
      expect(collection.suggestions.map(&:value)).to include(Date.current.to_fs(:db))
    end
  end
end
