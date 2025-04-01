# frozen_string_literal: true

require "csv"

class ResourcesController < ApplicationController
  def index
    collection = Collection.with_params(params).apply(Resource.all)

    respond_to do |format|
      format.html { render locals: { collection: } }
      format.csv { render body: csv }
    end
  end

  def activate
    collection = Collection.with_params(params).apply(Resource.all)

    collection.items.update_all(active: true) if collection.id.any? # rubocop:disable Rails/SkipsModelValidations

    redirect_back fallback_location: resources_path, status: :see_other
  end

  private

  def csv
    items = Resource.where(id: params[:id])

    CSV.generate do |csv|
      csv << %w[id name]
      items.pluck(:id, :name).each { |item| csv << item }
    end
  end

  class Collection < Katalyst::Tables::Collection::Base
    include Katalyst::Tables::Collection::Query

    config.paginate = { limit: 5 }
    config.sorting = :name

    attribute :search, :search, scope: :table_search
    attribute :id, :integer, multiple: true
    attribute :name, :string
    attribute :category, :enum
    attribute :active, :boolean
    attribute :created_at, :date
    attribute :index, :integer
  end
end
