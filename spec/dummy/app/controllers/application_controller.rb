# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Katalyst::Tables::Backend

  helper Katalyst::Tables::Frontend
  helper Pagy::Frontend

  def show; end
end
