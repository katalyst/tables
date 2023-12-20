# frozen_string_literal: true

require "rails_helper"

RSpec.describe Nested::ChildrenController do
  describe "GET index" do
    before { get "/parent/#{parent.id}/children" }

    let(:parent) { create(:parent) }

    it { expect(response).to have_http_status(:ok) }

    it "renders the index template" do
      expect(response).to have_rendered("nested/children/index")
    end

    it "renders the child partial" do
      expect(response).to have_rendered("nested/children/_child")
    end
  end
end
