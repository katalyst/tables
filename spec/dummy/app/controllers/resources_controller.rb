# frozen_string_literal: true

require "csv"

class ResourcesController < ApplicationController
  def index
    collection = Collection.with_params(params).apply(Resource.all)

    respond_to do |format|
      format.html { render locals: { collection: } }
      format.csv { render body: generate_csv_from_collection(collection:) }
    end
  end

  def activate
    collection = Collection.with_params(params).apply(Resource.all)

    collection.items.update_all(active: true) if collection.id.any? # rubocop:disable Rails/SkipsModelValidations

    redirect_back fallback_location: resources_path, status: :see_other
  end

  private

  def generate_csv_from_collection(collection:)
    CSV.generate do |csv|
      csv << %w[id name]
      collection.items.pluck(:id, :name).each { |item| csv << item }
    end
  end

  class Collection < Katalyst::Tables::Collection::Base
    include Katalyst::Tables::Collection::Query

    config.search_scope = :table_search
    config.sorting = :name

    attribute :id, default: -> { [] }
    attribute :name, :string
    attribute :category, default: -> { [] }
    attribute :active, :boolean
  end
end
