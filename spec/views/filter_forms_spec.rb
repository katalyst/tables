# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Filter Forms" do
  subject(:collection) { Examples::SearchCollection.with_params(params).apply(items) }

  let(:items) { build(:relation) }
  let(:params) { ActionController::Parameters.new(search: "query") }
  let(:template) { Test::Template.new }

  before do
    allow(items).to receive(:search).and_return(items)
    allow(template.controller).to receive(:resources_path).and_return("/resources")
  end

  it "creates a form from the collection" do
    actual = template.form_with(model: collection) { |form| form.text_field(:search) }

    expect(actual).to match_html(<<~HTML)
      <form action="/resources" accept-charset="UTF-8" method="post">
        <input type="text" value="query" name="search" id="search" />
      </form>
    HTML
  end
end
