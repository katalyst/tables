# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/sorting" do
  before do
    create_list(:resource, 3)
  end

  it "supports sorting" do
    visit "/resources"

    expect(page).to have_css("tr:first-child", text: "Resource 1")

    click_on "Resource partial"

    expect(page).to have_current_path("/resources?sort=name+desc")
    expect(page).to have_css("tr:first-child", text: "Resource 3")

    click_on "Resource partial"

    expect(page).to have_current_path("/resources")
    expect(page).to have_css("tr:first-child", text: "Resource 1")
  end

  it "shows the default sort" do
    visit "/resources"

    expect(page).to have_css("thead th[data-sort='asc'] a[href$='name+desc']")
  end

  context "with a sort applied" do
    it "shows the sort" do
      visit "/resources?sort=name+desc"

      expect(page).to have_css("thead th[data-sort='desc'] a[href='/resources']")
    end
  end

  context "when a new filter is applied" do
    it "retains sorting" do
      visit "/resources?sort=name+desc"

      fill_in "Search", with: "Resource"
      click_on "Apply"

      expect(page).to have_current_path(%r{q=Resource})
      expect(page).to have_current_path(%r{sort=name\+desc})
    end
  end

  context "when paginating" do
    it "retains sorting" do
      create_list(:resource, 3)

      visit "/resources?sort=name+desc"

      click_on ">"

      expect(page).to have_current_path(%r{page=2})
      expect(page).to have_current_path(%r{sort=name\+desc})
    end
  end
end
