# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResourcesController do
  describe "GET /resources" do
    before { get "/resources" }

    it { expect(response).to have_http_status(:ok) }

    it "renders the index template" do
      expect(response).to have_rendered("resources/index")
    end

    it "renders the resource partial" do
      expect(response).to have_rendered("resources/_resource")
    end
  end

  describe "GET /resources.csv" do
    let(:action) { get "/resources.csv" }

    it "renders successfully" do
      action
      expect(response).to have_http_status(:ok)
    end

    it "renders a csv" do
      create_list(:resource, 2)
      action
      expect(response.body).to eq(<<~CSV)
        id,name
        1,Resource 1
        2,Resource 2
      CSV
    end

    it "filters the csv when id is provided" do
      create_list(:resource, 2)
      get "/resources.csv", params: { id: [2] }
      expect(response.body).to eq(<<~CSV)
        id,name
        2,Resource 2
      CSV
    end
  end

  describe "PUT /resources/active" do
    def active_params(*resources)
      { id: resources.pluck(:id) }
    end

    it "redirects back" do
      _, second, third = create_list(:resource, 3)
      put activate_resources_path, params: active_params(second, third)
      expect(response).to redirect_to(resources_path)
    end

    it "updates the ordinal of the faqs" do
      _, second, third = create_list(:resource, 3)
      expect do
        put activate_resources_path, params: active_params(second, third)
      end.to(
        change { Resource.active.pluck(:id) }.from([]).to([second, third].pluck(:id)),
      )
    end
  end
end
