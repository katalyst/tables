# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Tables::Collection::Type::Query do
  subject(:type) { described_class.new }

  describe "#filterable?" do
    it { expect(type).not_to be_filterable }
  end
end
