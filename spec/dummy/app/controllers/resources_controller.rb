# frozen_string_literal: true

require "csv"

class ResourcesController < ApplicationController
  def index
    collection = Collection.with_params(params).apply(Resource.all)
    table      = Katalyst::Turbo::TableComponent.new(id: helpers.dom_id(Resource, "list"), collection:)
    table.extend(Katalyst::Tables::Selectable)
    table.with_selection

    respond_to do |format|
      format.turbo_stream { render table } if self_referred?
      format.html { render locals: { table: } }
      format.csv do
        render(body: CSV.generate do |csv|
          csv << %w[id name]
          collection.items.pluck(:id, :name).each do |item|
            csv << item
          end
        end)
      end
    end
  end

  def activate
    collection = Collection.with_params(params).apply(Resource.all)
    collection.items.update_all(active: true) # rubocop:disable Rails/SkipsModelValidations
    redirect_back fallback_location: resources_path, status: :see_other
  end

  class Collection < Katalyst::Tables::Collection::Base
    config.sorting = :name

    attribute :id, default: -> { [] }

    def filter
      self.items = items.where(id:) if id.any?
    end
  end
end
