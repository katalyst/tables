# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Katalyst::Tables::Backend

  def show
    head :no_content
  end
end
