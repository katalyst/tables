# frozen_string_literal: true

require "active_record"

RSpec.shared_context "when collection has attribute" do |attribute = :col|
  let(:items) { build(:relation, attributes: [attribute]) }
end

RSpec.shared_context "when collection has scope" do |attribute = :col|
  before do
    allow(items).to receive("order_by_#{attribute}").and_return(items)
  end
end
