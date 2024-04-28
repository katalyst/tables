# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/pagination" do
  context "when there are more than 5 results" do
    it "supports pagination" do
      people = create_list(:person, 6)

      visit "/people"

      expect(page).to have_css("td", text: people.first.name)

      click_on ">"

      expect(page).to have_css("td", text: people.last.name)
    end
  end

  context "when a new filter is applied" do
    it "clears pagination" do
      create_list(:person, 6)

      visit "/people?page=2"

      fill_in "Search", with: "People"

      expect(page).to have_current_path("/people?search=People")
    end
  end

  context "when a new sort is applied" do
    it "clears pagination" do
      create_list(:person, 6)

      visit "/people?page=2"

      click_on "Name"

      expect(page).to have_current_path("/people?sort=name+desc")
    end
  end
end
