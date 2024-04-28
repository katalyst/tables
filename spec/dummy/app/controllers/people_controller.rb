# frozen_string_literal: true

class PeopleController < ApplicationController
  def index
    @people = Collection.with_params(params).apply(Person.all)
  end

  class Collection < Katalyst::Tables::Collection::Base
    config.paginate = { anchor_string: "data-turbo-action=\"replace\"", items: 5 }
    config.sorting = :name

    attribute :search, default: -> { "" }

    def filter
      self.items = items.where("name LIKE ?", "%#{search}%") if search.present?
    end
  end
end
