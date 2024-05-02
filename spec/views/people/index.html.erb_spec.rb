# frozen_string_literal: true

require "rails_helper"

RSpec.describe "people/index" do
  before do
    people
    assign(:people, PeopleController::Collection.with_params(params).apply(Person.all))
    view.extend(Katalyst::Tables::Frontend)
    view.extend(Pagy::Frontend)
  end

  let(:people) { create_list(:person, 2) }
  let(:params) { ActionController::Parameters.new }

  it "renders a name column" do
    render
    expect(rendered).to have_css("thead>tr>th", text: "Name")
  end

  it "renders a list of people" do
    render
    expect(rendered).to have_css("tr>td", text: /Person \d/, count: 2)
  end

  context "when there are no people" do
    let(:people) { nil }

    it "shows a placeholder message" do
      render
      expect(rendered).to have_css("caption", text: "No people found.")
    end
  end

  context "when there are more than 5 results" do
    let(:people) { create_list(:person, 10) }

    it "renders pagination options" do
      render
      expect(rendered).to have_css("a[data-turbo-action='replace']", text: "2")
    end
  end
end
