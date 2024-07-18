# frozen_string_literal: true

class PeopleController < ApplicationController
  def index
    collection = Collection.with_params(params).apply(Person.active)

    render locals: { collection: }
  end

  def archived
    collection = Collection.with_params(params).apply(Person.archived)

    render locals: { collection: }
  end

  def archive
    Person.active.where(id: params[:id]).each do |person|
      person.update!(active: false)
    end

    redirect_back fallback_location: people_path, status: :see_other
  end

  def restore
    Person.archived.where(id: params[:id]).each do |person|
      person.update!(active: true)
    end

    redirect_back fallback_location: people_path, status: :see_other
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
