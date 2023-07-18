# frozen_string_literal: true

require "active_record"

RSpec.shared_context "with collection" do
  let(:collection) { instance_double(ActiveRecord::Relation).as_null_object }
  let(:model) { instance_double(ActiveRecord::Base).as_null_object }

  before do
    allow(collection).to receive_messages(reorder: collection, model: model)
    allow(model).to receive(:has_attribute?).and_return(false)
  end
end

RSpec.shared_context "with collection data" do |values|
  let(:collection) do
    record = Struct.new(:col)
    values.map { |value| record.new(value) }
  end
end

RSpec.shared_context "with collection attribute" do |attribute: "col"|
  before do
    allow(model).to receive(:has_attribute?).with(attribute).and_return(true)
  end
end

RSpec.shared_context "with collection scope" do |scope: :order_by_col|
  let(:collection) do
    # use a relaxed double to add scope
    spy(ActiveRecord::Relation).tap do |collection| # rubocop:disable RSpec/VerifiedDoubles
      allow(collection).to receive(scope).and_return(collection)
    end
  end
end
