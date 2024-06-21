# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/filtering" do
  before do
    create_list(:person, 6)
  end

  it "applies filters" do
    visit people_path

    fill_in "Search", with: "1"
    click_on "Filter"

    expect(page).to have_current_path(people_path(search: "1"))
    expect(page).to have_css("input[type=search][value='1']")
    expect(page).to have_css("td", text: "Person 1")
    expect(page).to have_no_css("td", text: "Person 3")
  end

  it "clears filters" do
    visit people_path(search: "1")

    expect(page).to have_no_css("td", text: "Person 3")

    find("input[type=search]").click
    page.driver.browser.keyboard.type(:escape)
    page.driver.browser.keyboard.type(:enter)

    expect(page).to have_current_path(people_path(search: ""))
    expect(page).to have_css("td", text: "Person 3")

    expect(page).to have_css("input[type=search]:focus")
  end

  context "when there are no results" do
    it "shows a placeholder message" do
      visit people_path(search: "xxxxxx")

      expect(page).to have_css("caption", text: "No people found.")
    end
  end

  context "when paginating" do
    it "retains filter" do
      visit people_path(search: "Person")

      click_on ">"

      expect(page).to have_current_path(%r{page=2})
      expect(page).to have_current_path(%r{search=Person})
      expect(page).to have_css("input[type=search][value='Person']")
    end
  end

  context "when sorting" do
    it "retains filter" do
      visit people_path(search: "Person")

      click_on "Name"

      expect(page).to have_current_path("/people?search=Person&sort=name+desc")
      expect(page).to have_css("input[type=search][value='Person']")
    end
  end

  context "with history navigation" do
    it "restores search state" do
      visit people_path

      fill_in "Search", with: "Person"
      click_on "Filter"

      expect(page).to have_current_path(people_path(search: "Person"))

      click_on "Home" # leave the page with turbo

      expect(page).to have_css("h1", text: "Katalyst Tables")

      page.go_back

      expect(page).to have_current_path(people_path(search: "Person"))
      expect(page).to have_css("input[type=search][value='Person']")
    end
  end
end
