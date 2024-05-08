# frozen_string_literal: true

require "rails_helper"

RSpec.describe "orderable" do
  before do
    %i[first second third].each_with_index do |n, i|
      create(:faq, question: n, answer: n, ordinal: i)
    end
  end

  it "supports mouse re-ordering" do
    visit "/faqs"

    within("tbody") do
      first = page.find("tr:first-child td.ordinal")
      last  = page.find("tr:last-child td.ordinal")
      first.drag_to(last, steps: 10)
    end

    expect(page).to have_css("tr:last-child td", text: "first")

    expect(Faq.all).to contain_exactly(
      have_attributes(question: "second", ordinal: 0),
      have_attributes(question: "third", ordinal: 1),
      have_attributes(question: "first", ordinal: 2),
    )
  end
end
