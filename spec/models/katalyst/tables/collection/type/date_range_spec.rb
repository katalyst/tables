# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Type::DateRange do
  let(:type) { described_class.new }

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
end
