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
    include Tables::HasTableContent

    attr_reader :collection, :object_name

    config_component :header_row, default: "Katalyst::Tables::HeaderRowComponent"
    config_component :header_cell, default: "Katalyst::Tables::HeaderCellComponent"
    config_component :body_row, default: "Katalyst::Tables::BodyRowComponent"
    config_component :body_cell, default: "Katalyst::Tables::BodyCellComponent"
    config_component :caption, default: "Katalyst::Tables::EmptyCaptionComponent"

    # Construct a new table component. This entry point supports a large number
    # of options for customizing the table. The most common options are:
    # - `collection`: the collection to render
    # - `sorting`: the sorting to apply to the collection (defaults to collection.storing if available)
    # - `header`: whether to render the header row (defaults to true, supports options)
    # - `caption`: whether to render the caption (defaults to true, supports options)
    # - `object_name`: the name of the object to use for partial rendering (defaults to collection.model_name.i18n_key)
    # - `partial`: the name of the partial to use for rendering each row (defaults to collection.model_name.param_key)
    # - `as`: the name of the local variable to use for rendering each row (defaults to collection.model_name.param_key)
    # In addition to these options, standard HTML attributes can be passed which will be added to the table tag.
    def initialize(collection:,
                   sorting: nil,
                   header: true,
                   caption: false,
                   **html_attributes)
      @collection = collection

      # sorting: instance of Katalyst::Tables::Backend::SortForm. If not provided will be inferred from the collection.
      @sorting = sorting || html_attributes.delete(:sort) # backwards compatibility with old `sort` option

      # header: true means render the header row, header: false means no header row, if a hash, passes as options
      @header         = header
      @header_options = (header if header.is_a?(Hash)) || {}

      # caption: true means render the caption, caption: false means no caption, if a hash, passes as options
      @caption         = caption
      @caption_options = (caption if caption.is_a?(Hash)) || {}

      super(**html_attributes)
    end

    def call
      tag.table(**html_attributes) do
        concat(caption)
        concat(thead)
        concat(tbody)
      end
    end

    def caption
      caption_component&.new(self)&.render_in(view_context) if @caption
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
      body_row_component.new(self, record).render_in(view_context) do |row|
        row_proc.call(row, record)
      end
    end

    def sorting
      return @sorting if @sorting.present?

      collection.sorting if collection.respond_to?(:sorting)
    end

    def inspect
      "#<#{self.class.name} collection: #{collection.inspect}>"
    end
  end
end
