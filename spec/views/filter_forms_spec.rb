# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Filter Forms" do
  subject(:collection) { Examples::SearchCollection.with_params(params).apply(items) }

  let(:items) { create_list(:person, 1) && Person.all }
  let(:params) { ActionController::Parameters.new(search: "query") }

  before do
    allow(items).to receive(:search).and_return(items)
    allow(controller).to receive(:resources_path).and_return("/resources")
  end

  it "creates a form from the collection" do
    actual = form_with(model: collection) { |form| form.text_field(:search) }

    expect(actual).to match_html(<<~HTML)
      <form action="/people" accept-charset="UTF-8" method="post">
        <input type="text" value="query" name="search" id="search" />
      </form>
    HTML
  end

  context "with a filter collection" do
    subject(:collection) { Examples::FilterCollection.new(param_key: "filters").with_params(params).apply(items) }

    let(:params) { ActionController::Parameters.new(filters: { search: "query" }) }

    it "nests the names appropriately" do
      actual = form_with(model: collection) { |form| form.text_field(:search) }

      expect(actual).to match_html(<<~HTML)
        <form action="/people" accept-charset="UTF-8" method="post">
          <input type="text" value="query" name="filters[search]" id="filters_search" />
        </form>
      HTML
    end
  end
end
