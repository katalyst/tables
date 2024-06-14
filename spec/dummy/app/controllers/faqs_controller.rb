# frozen_string_literal: true

class FaqsController < ApplicationController
  before_action :set_faq, only: :show

  def index
    render locals: { collection: Faq.all }
  end

  def show
    render locals: { faq: @faq }
  end

  def order
    order_params[:faqs].each do |id, attrs|
      Faq.find(id).update(attrs)
    end

    redirect_back(fallback_location: faqs_path, status: :see_other)
  end

  private

  def set_faq
    @faq = Faq.find(params[:id])
  end

  def order_params
    params.require(:order).permit(faqs: [:ordinal])
  end
end
