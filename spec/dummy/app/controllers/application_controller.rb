# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Katalyst::Tables::Backend

  helper Katalyst::Tables::Frontend

  def show
    head :no_content
  end
end
