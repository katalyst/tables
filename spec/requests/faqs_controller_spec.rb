# frozen_string_literal: true

require "rails_helper"

RSpec.describe FaqsController do
  describe "GET /faqs/index" do
    it "renders a successful response" do
      create_list(:faq, 2)
      get faqs_path
      expect(response).to be_successful
    end
  end

  describe "PATCH /faqs/order" do
    def order_params(*faqs)
      { order: { faqs: faqs.map.with_index { |faq, index| [faq.id, { ordinal: index }] }.to_h } }
    end

    it "redirects back" do
      first, second = create_list(:faq, 2)
      patch order_faqs_path, params: order_params(second, first)
      expect(response).to redirect_to(faqs_path)
    end

    it "updates the ordinal of the faqs" do
      first, second = create_list(:faq, 2)
      expect do
        patch order_faqs_path, params: order_params(second, first)
      end.to(
        change(Faq, :all).from([first, second]).to([second, first]),
      )
    end
  end
end
