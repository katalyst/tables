# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/query" do
  before do
    create_list(:resource, 6)
  end

  it "applies filters" do
    visit resources_path

    fill_in("Search", with: "1").click
    click_on("Apply")

    expect(page).to have_current_path(resources_path(q: "1"))
    expect(find("[role=combobox]").value).to eq("1")
    expect(page).to have_css("td", text: "Resource 1")
    expect(page).to have_no_css("td", text: "Resource 3")
  end

  it "clears filters" do
    visit resources_path(q: "1")

    expect(page).to have_no_css("td", text: "Resource 3")

    find("[role=combobox]").click
    page.driver.browser.keyboard.type(:escape)

    expect(page).to have_current_path(resources_path)
    expect(page).to have_css("td", text: "Resource 3")
  end

  context "when there are no results" do
    it "shows a placeholder message" do
      visit resources_path(search: "xxxxxx")

      expect(page).to have_css("caption", text: "No resources found.")
    end
  end

  context "when paginating" do
    it "retains filter" do
      visit resources_path(q: "Resource")

      click_on ">"

      expect(page).to have_current_path(%r{page=2})
      expect(page).to have_current_path(%r{q=Resource})
      expect(find("[role=combobox]").value).to eq("Resource")
    end
  end

  context "when sorting" do
    it "retains filter" do
      visit resources_path(q: "Resource")

      click_on "Resource partial" # name column header

      expect(page).to have_current_path("/resources?q=Resource&sort=name+desc")
      expect(find("[role=combobox]").value).to eq("Resource")
    end
  end

  context "with history navigation" do
    it "restores search state" do
      visit resources_path

      fill_in("Search", with: "Resource").click
      click_on "Apply"

      expect(page).to have_current_path(resources_path(q: "Resource"))

      click_on "Home" # leave the page with turbo

      expect(page).to have_css("h1", text: "Katalyst Tables")

      page.go_back

      expect(page).to have_current_path(resources_path(q: "Resource"))
      expect(find("[role=combobox]").value).to eq("Resource")
    end
  end
end
