# frozen_string_literal: true

module Katalyst
  # A component for rendering a table from a collection, with a header row.
  # ```erb
  # <%= Katalyst::TableComponent.new(collection: @people) do |row, person| %>
  #   <%= row.cell :name do |cell| %>
  #     <%= link_to cell.value, person %>
  #   <% end %>
  #   <%= row.cell :email %>
  # <% end %>
  # ```
  class TableComponent < ViewComponent::Base
    include ActiveSupport::Configurable
    include Tables::Frontend::Helper

    attr_reader :collection, :sort, :object_name

    # Workaround: ViewComponent::Base.config is incompatible with ActiveSupport::Configurable
    @_config = Class.new(Configuration).new

    config_accessor :header_row
    config_accessor :header_cell
    config_accessor :body_row
    config_accessor :body_cell

    def initialize(collection:,
                   sort: nil,
                   header: true,
                   object_name: collection.try(:model_name)&.i18n_key,
                   **html_options)
      super

      @collection   = collection
      @sort         = sort
      @header       = header
      @object_name  = object_name
    end

    def call
      tag.table(**@html_options) do
        thead + tbody
      end
    end

    def thead
      return "".html_safe unless @header

      tag.thead do
        concat(render_header)
      end
    end

    def tbody
      tag.tbody do
        collection.each do |record|
          concat(render_row(record))
        end
      end
    end

    def render_header
      # extract the column's block from the slot and pass it to the cell for rendering
      self.class.header_row_component.new(self).render_in(view_context, &@__vc_render_in_block)
    end

    def render_row(record)
      # extract the column's block from the slot and pass it to the cell for rendering
      block = @__vc_render_in_block
      self.class.body_row_component.new(self, record).render_in(view_context) do |row|
        block.call(row, record)
      end
    end

    def self.header_row_component
      @header_row_component ||= const_get(config.header_row || "Katalyst::Tables::HeaderRowComponent")
    end

    def self.header_cell_component
      @header_cell_component ||= const_get(config.header_cell || "Katalyst::Tables::HeaderCellComponent")
    end

    def self.body_row_component
      @body_row_component ||= const_get(config.body_row || "Katalyst::Tables::BodyRowComponent")
    end

    def self.body_cell_component
      @body_cell_component ||= const_get(config.body_cell || "Katalyst::Tables::BodyCellComponent")
    end
  end
end