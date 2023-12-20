# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResourcesController do
  describe "GET index" do
    before { get "/resources" }

    it { expect(response).to have_http_status(:ok) }

    it "renders the index template" do
      expect(response).to have_rendered("resources/index")
    end

    it "renders the resource partial" do
      expect(response).to have_rendered("resources/_resource")
    end
  end
end
