# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Type::Search do
  def new_collection(params = {})
    allow(Resource).to receive(:custom) { |v| Resource.where(custom: v) }
    Class.new(Katalyst::Tables::Collection::Base) do
      include Katalyst::Tables::Collection::Query

      attribute :search, :search, scope: :custom
    end.with_params(params)
  end

  def filter(collection, scope = Resource.all, key: "search")
    attribute = collection.instance_variable_get(:@attributes)[key]
    attribute.type.filter(scope, attribute)
  end

  describe "#filter" do
    it("does not run by default") do
      expect(filter(new_collection).to_sql).to eq(Resource.all.to_sql)
    end

    it "supports string matching" do
      expect(filter(new_collection(search: "aaron")).to_sql).to eq(Resource.where(custom: "aaron").to_sql)
    end
  end
end
