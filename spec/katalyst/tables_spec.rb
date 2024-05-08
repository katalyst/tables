# frozen_string_literal: true

RSpec.describe Katalyst::Tables do
  context "when frontend is loaded" do
    include Katalyst::Tables::Frontend

    it { expect(self).to respond_to(:table_with) }
  end
end
