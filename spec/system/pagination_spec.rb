# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/pagination" do
  context "when there are more than 5 results" do
    it "supports pagination" do
      resources = create_list(:resource, 6)

      visit "/resources"

      expect(page).to have_css("td", text: resources.first.name)

      click_on ">"

      expect(page).to have_css("td", text: resources.last.name)
    end
  end

  context "when a new filter is applied" do
    it "clears pagination" do
      create_list(:resource, 6)

      visit "/resources?page=2"

      fill_in "Search", with: "Resource"
      click_on "Apply"

      expect(page).to have_current_path("/resources?q=Resource")
    end
  end

  context "when a new sort is applied" do
    it "clears pagination" do
      create_list(:resource, 6)

      visit "/resources?page=2"

      click_on "Resource partial" # label for name column

      expect(page).to have_current_path("/resources?sort=name+desc")
    end
  end
end
