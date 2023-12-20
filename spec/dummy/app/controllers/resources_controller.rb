# frozen_string_literal: true

class ResourcesController < ApplicationController
  def index
    collection = Katalyst::Tables::Collection::Base.with_params(params).apply(Resource.all)

    render locals: { collection: collection }
  end
end
