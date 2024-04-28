# frozen_string_literal: true

require "rails_helper"

RSpec.describe PeopleController do
  describe "GET /index" do
    it "renders a successful response" do
      create(:person)
      get people_path
      expect(response).to be_successful
    end
  end
end
