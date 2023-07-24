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
    include Tables::ConfigurableComponent
    include Tables::HasHtmlAttributes

    attr_reader :collection, :sorting, :object_name

    config_component :header_row, default: "Katalyst::Tables::HeaderRowComponent"
    config_component :header_cell, default: "Katalyst::Tables::HeaderCellComponent"
    config_component :body_row, default: "Katalyst::Tables::BodyRowComponent"
    config_component :body_cell, default: "Katalyst::Tables::BodyCellComponent"

    # Construct a new table component. This entry point supports a large number
    # of options for customizing the table. The most common options are:
    # - `collection`: the collection to render
    # - `sorting`: the sorting to apply to the collection (defaults to collection.storing if available)
    # - `header`: whether to render the header row (defaults to true)
    # - `object_name`: the name of the object to use for partial rendering (defaults to collection.model_name.i18n_key)
    # - `partial`: the name of the partial to use for rendering each row (defaults to collection.model_name.param_key)
    # - `as`: the name of the local variable to use for rendering each row (defaults to collection.model_name.param_key)
    #
    # In addition to these options, standard HTML attributes can be passed which will be added to the table tag.
    #
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
      @sorting        = sorting || sort || default_sorting

      # header: true means render the header row, header: false means no header row, if a hash, passes as options
      @header         = header
      @header_options = (header if header.is_a?(Hash)) || {}

      # model configuration, derived from collection.model_name if collection responds to model_name
      @object_name    = object_name # defaults to collection.model_name.i18n_key
      @partial        = partial # defaults to collection.model_name.param_key
      @as             = as # defaults to collection.model_name.param_key
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

    def default_sorting
      collection.sorting if collection.respond_to?(:sorting)
    end
  end
end
