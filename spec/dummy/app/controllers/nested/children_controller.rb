# frozen_string_literal: true

module Nested
  class ChildrenController < ApplicationController
    before_action :set_parent

    def index
      collection = Katalyst::Tables::Collection::Base.with_params(params.except(:parent_id))
                     .apply(@parent.children)

      render locals: { collection: collection }
    end

    def set_parent
      @parent = Parent.find(params[:parent_id])
    end
  end
end
