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
    include Katalyst::HtmlAttributes
    include Tables::ConfigurableComponent
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
    # - `generate_ids`: whether to generate ids for each row (defaults to true)
    # - `object_name`: the name of the object to use for partial rendering (defaults to collection.model_name.i18n_key)
    # - `partial`: the name of the partial to use for rendering each row (defaults to to_partial_path on the object)
    # - `as`: the name of the local variable to use for rendering each row (defaults to collection.model_name.param_key)
    # In addition to these options, standard HTML attributes can be passed which will be added to the table tag.
    def initialize(collection:,
                   sorting: nil,
                   header: true,
                   caption: true,
                   generate_ids: true,
                   **html_attributes)
      @collection = collection

      # sorting: instance of Katalyst::Tables::Collection::SortForm.
      # If not provided will be inferred from the collection.
      @sorting = sorting || html_attributes.delete(:sort) # backwards compatibility with old `sort` option

      # header: true means render the header row, header: false means no header row, if a hash, passes as options
      @header         = header
      @header_options = (header if header.is_a?(Hash)) || {}

      # caption: true means render the caption, caption: false means no caption, if a hash, passes as options
      @caption         = caption
      @caption_options = (caption if caption.is_a?(Hash)) || {}

      @generate_ids = generate_ids

      super(**html_attributes)
    end

    def id
      html_attributes[:id]
    end

    def caption?
      @caption.present?
    end

    def caption
      caption_component&.new(self)
    end

    def header?
      @header.present?
    end

    def header_row
      header_row_component.new(self, **@header_options)
    end

    def body_row(record)
      body_row_component.new(self, record)
    end

    def sorting
      return @sorting if @sorting.present?

      collection.sorting if collection.respond_to?(:sorting)
    end

    def generate_ids?
      @generate_ids.present?
    end

    def inspect
      "#<#{self.class.name} collection: #{collection.inspect}>"
    end

    define_html_attribute_methods(:thead_attributes)
    define_html_attribute_methods(:tbody_attributes)

    # Backwards compatibility with tables 1.0
    alias_method :options, :html_attributes=
  end
end
