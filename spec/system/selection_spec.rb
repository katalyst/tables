# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Selection" do
  let(:csv_file) { File.join(Capybara.save_path, "resources.csv") }

  after { FileUtils.rm_rf csv_file }

  it "shows selections" do
    create(:resource)

    visit resources_path

    within("tbody") do
      first("input[type=checkbox]").click
    end

    expect(page).to have_css(".tables--selection--form", text: "1 resource selected")
  end

  it "retains selections on re-render" do
    create(:resource)

    visit resources_path

    within("tbody") do
      first("input[type=checkbox]").click
    end

    expect(page).to have_css(".tables--selection--form", text: "1 resource selected")

    click_on "Resource partial" # re-order table

    # wait for update to complete
    expect(page).to have_css("thead th[data-sort=desc]")
    # check that selection is retained
    expect(page).to have_css("input[type=checkbox]:checked") # rubocop:disable Capybara/SpecificMatcher
  end

  it "offers a download link when a selection has been made" do
    create(:resource)

    visit resources_path

    expect(page).to have_no_button(text: "Download")

    within("tbody") do
      first("input[type=checkbox]").click
    end

    expect(page).to have_button(text: "Download")
  end

  it "hides the download link when a selection has been cleared" do
    create(:resource)

    visit resources_path

    expect(page).to have_no_button(text: "Download")

    within("tbody") do
      first("input[type=checkbox]").click
    end

    expect(page).to have_button(text: "Download")

    within("tbody") do
      first("input[type=checkbox]").click
    end

    expect(page).to have_no_button(text: "Download")
  end

  it "downloads selected rows" do
    resource, = create_list(:resource, 2)

    visit resources_path

    within("tbody") do
      first("input[type=checkbox]").click
    end

    click_on "Download"

    Timeout.timeout(2) do
      sleep 0.01 until File.exist?(csv_file)
    end

    csv = CSV.read(csv_file, headers: true)

    expect(csv.map(&:to_h)).to contain_exactly({
                                                 "id"   => resource.id.to_s,
                                                 "name" => resource.name,
                                               })
  end

  it "activates selected rows" do
    resource, = create_list(:resource, 2)

    visit resources_path

    within("tbody") do
      first("input[type=checkbox]").click
    end

    click_on "Activate"

    expect(page).to have_css("tr#resource_#{resource.id} > td.active", text: "Yes")

    expect(resource.reload).to be_active
  end
end
