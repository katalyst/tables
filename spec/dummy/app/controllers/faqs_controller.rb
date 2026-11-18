# frozen_string_literal: true

class FaqsController < ApplicationController
  before_action :set_faq, only: :show

  def index
    respond_to do |format|
      format.html { render locals: { collection: Faq.all } }
    end
  end

  def show
    respond_to do |format|
      format.html { render locals: { faq: @faq } }
    end
  end

  def order
    order_params[:faqs].each do |id, attrs|
      Faq.find(id).update(attrs)
    end

    redirect_back_or_to(faqs_path, status: :see_other)
  end

  private

  def set_faq
    @faq = Faq.find(params.expect(:id))
  end

  def order_params
    params.expect(order: { faqs: [[:ordinal]] })
  end
end
