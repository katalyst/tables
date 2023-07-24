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
    include Tables::HasHtmlAttributes

    attr_reader :collection, :sorting, :object_name

    # Workaround: ViewComponent::Base.config is incompatible with ActiveSupport::Configurable
    @_config = Class.new(Configuration).new

    config_accessor :header_row_component
    config_accessor :header_cell_component
    config_accessor :body_row_component
    config_accessor :body_cell_component

    # rubocop:disable Metrics/ParameterLists
    def initialize(collection:,
                   sorting: nil,
                   sort: nil, # backwards compatibility
                   header: true,
                   object_name: nil,
                   partial: nil,
                   as: nil,
                   **html_attributes)
      super(**html_attributes)

      @collection     = collection
      @sorting        = sorting || sort
      @header         = header
      @header_options = (header if header.is_a?(Hash)) || {}
      @object_name    = object_name
      @partial        = partial
      @as             = as

      with_model_name_defaults
    end
    # rubocop:enable Metrics/ParameterLists

    def call
      tag.table(**html_attributes) do
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
      header_row_component.new(self, **@header_options).render_in(view_context, &row_proc)
    end

    def render_row(record)
      # extract the column's block from the slot and pass it to the cell for rendering
      block = row_proc
      body_row_component.new(self, record).render_in(view_context) do |row|
        block.call(row, record)
      end
    end

    def header_row_component
      @header_row_component ||= self.class.const_get(config.header_row || "Katalyst::Tables::HeaderRowComponent")
    end

    def header_cell_component
      @header_cell_component ||= self.class.const_get(config.header_cell || "Katalyst::Tables::HeaderCellComponent")
    end

    def body_row_component
      @body_row_component ||= self.class.const_get(config.body_row || "Katalyst::Tables::BodyRowComponent")
    end

    def body_cell_component
      @body_cell_component ||= self.class.const_get(config.body_cell || "Katalyst::Tables::BodyCellComponent")
    end

    def row_proc
      @row_proc ||= @__vc_render_in_block || method(:row_partial)
    end

    def row_partial(row, record = nil)
      render(partial: @partial, variants: [:row], locals: { @as => record, row: row })
    end

    private

    # rubocop:disable Naming/MemoizedInstanceVariableName
    def with_model_name_defaults
      return unless collection.respond_to?(:model_name)

      @object_name ||= collection.model_name.i18n_key
      @partial     ||= collection.model_name.param_key.to_s
      @as          ||= collection.model_name.param_key.to_sym
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end
end
