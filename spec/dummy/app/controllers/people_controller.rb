# frozen_string_literal: true

class PeopleController < ApplicationController
  def index
    @people = Collection.with_params(params).apply(Person.all)
  end

  def show
    @person = Person.find(params[:id])
  end

  # Note: legacy style collection, testing backwards compatibility (vs Query)
  class Collection < Katalyst::Tables::Collection::Base
    config.paginate = { items: 5 }
    config.sorting = "name asc"

    attribute :search, default: -> { "" }

    def filter
      self.items = items.where("name LIKE ?", "%#{search}%") if search.present?
    end
  end
end
