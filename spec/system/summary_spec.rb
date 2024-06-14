# frozen_string_literal: true

require "rails_helper"

RSpec.describe "summary" do
  it "renders a summary table" do
    person = create(:person)

    visit person_path(person)

    expect(page).to have_css("td", text: person.name)
  end
end
