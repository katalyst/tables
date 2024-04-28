# frozen_string_literal: true

require "rails_helper"

RSpec.describe "index/sorting" do
  before do
    create_list(:person, 3)
  end

  it "supports sorting" do
    visit "/people"

    expect(page).to have_css("tr:first-child", text: "Person 1")

    click_on "Name"

    expect(page).to have_current_path("/people?sort=name+desc")
    expect(page).to have_css("tr:first-child", text: "Person 3")

    click_on "Name"

    expect(page).to have_current_path("/people")
    expect(page).to have_css("tr:first-child", text: "Person 1")
  end

  it "shows the default sort" do
    visit "/people"

    expect(page).to have_css("thead th[data-sort='asc'] a[href$='name+desc']")
  end

  context "with a sort applied" do
    it "shows the sort" do
      visit "/people?sort=name+desc"

      expect(page).to have_css("thead th[data-sort='desc'] a[href='/people']")
    end
  end

  context "when a new filter is applied" do
    it "retains sorting" do
      visit "/people?sort=name+desc"

      fill_in "Search", with: "Person"

      expect(page).to have_current_path(%r{search=Person})
      expect(page).to have_current_path(%r{sort=name\+desc})
    end
  end

  context "when paginating" do
    it "retains sorting" do
      create_list(:person, 3)

      visit "/people?sort=name+desc"

      click_on ">"

      expect(page).to have_current_path(%r{page=2})
      expect(page).to have_current_path(%r{sort=name\+desc})
    end
  end
end
