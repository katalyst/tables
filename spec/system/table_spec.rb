# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/table" do
  it "renders a table" do
    person = create(:person)

    visit people_path

    expect(page).to have_css("td", text: person.name)
  end

  context "when there are no results" do
    it "shows a placeholder message" do
      visit people_path

      expect(page).to have_css("caption", text: "No people found.")
    end
  end
end
