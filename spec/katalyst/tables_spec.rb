# frozen_string_literal: true

RSpec.describe Katalyst::Tables do
  it "has a version number" do
    expect(Katalyst::Tables::VERSION).not_to be_nil
  end

  context "when backend is loaded" do
    include Katalyst::Tables::Backend

    it { expect(self).to respond_to(:table_sort) }
  end

  context "when frontend is loaded" do
    include Katalyst::Tables::Frontend

    it { expect(self).to respond_to(:table_with) }
  end
end
