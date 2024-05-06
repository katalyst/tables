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
    include Tables::HasTableContent
    include Tables::Sortable

    attr_reader :collection, :object_name

    renders_one :caption, Katalyst::Tables::EmptyCaptionComponent
    renders_one :header_row, Katalyst::Tables::HeaderRowComponent
    renders_many :body_rows, Katalyst::Tables::BodyRowComponent

    define_html_attribute_methods(:thead_attributes)
    define_html_attribute_methods(:tbody_attributes)

    # Construct a new table component. This entry point supports a large number
    # of options for customizing the table. The most common options are:
    # - `collection`: the collection to render
    # - `header`: whether to render the header row (defaults to true, supports options)
    # - `caption`: whether to render the caption (defaults to true, supports options)
    # - `object_name`: the name of the object to use for partial rendering (defaults to collection.model_name.i18n_key)
    # - `partial`: the name of the partial to use for rendering each row (defaults to to_partial_path on the object)
    # - `as`: the name of the local variable to use for rendering each row (defaults to collection.model_name.param_key)
    # In addition to these options, standard HTML attributes can be passed which will be added to the table tag.
    def initialize(collection:,
                   header: true,
                   caption: true,
                   **html_attributes)
      @collection = normalize_collection(collection)

      # header: true means render the header row, header: false means no header row, if a hash, passes as options
      @header_options = header

      # caption: true means render the caption, caption: false means no caption, if a hash, passes as options
      @caption_options = caption

      @header_row_callbacks = []
      @body_row_callbacks = []
      @header_row_cell_callbacks = []
      @body_row_cell_callbacks = []

      super(**html_attributes)
    end

    def id
      html_attributes[:id]
    end

    def before_render
      super

      if @caption_options
        options = (@caption_options.is_a?(Hash) ? @caption_options : {})
        with_caption(self, **options)
      end

      if @header_options
        options = @header_options.is_a?(Hash) ? @header_options : {}
        with_header_row(**options) do |row|
          @header_row_callbacks.each { |callback| callback.call(row, record) }
          row_content(row, nil)
        end
      end

      collection.each do |record|
        with_body_row do |row|
          @body_row_callbacks.each { |callback| callback.call(row, record) }
          row_content(row, record)
        end
      end
    end

    def inspect
      "#<#{self.class.name} collection: #{collection.inspect}>"
    end

    delegate :header?, :body?, to: :@current_row

    def row
      @current_row
    end

    def record
      @current_record
    end

    # When rendering a row we pass the table to the row instead of the row itself. This lets the table define the
    # column entry points so it's easy to define column extensions in subclasses. When a user wants to set html
    # attributes on the row, they will call `row.html_attributes = { ... }`, so we need to proxy that call to the
    # current row (if set).
    def html_attributes=(attributes)
      if row.present?
        row.html_attributes = attributes
      else
        @html_attributes = HtmlAttributes.options_to_html_attributes(attributes)
      end
    end

    # Generates a column from values rendered as text.
    #
    # @param column [Symbol] the column's name, called as a method on the record
    # @param label [String|nil] the label to use for the column header
    # @param heading [boolean] if true, data cells will use `th` tags
    # @param ** [Hash] HTML attributes to be added to column cells
    # @param & [Proc] optional block to wrap the cell content
    # @return [void]
    #
    # @example Render a generic text column for any value that supports `to_s`
    #   <% row.cell :name %> # label => <th>Name</th>, data => <td>John Doe</td>
    def cell(column, label: nil, heading: false, **, &)
      with_cell(Tables::CellComponent.new(collection:, row:, column:, record:, label:, heading:, **), &)
    end

    # Is selection enabled for this table?
    def selectable?
      false
    end

    # Workaround for `ViewContext#select` method confusingly filling in for a missing Selectable concern.
    # @see Katalyst::Tables::Selectable
    def select
      raise NotImplementedError, "This table does not include the Selectable concern"
    end

    private

    # Extension point for subclasses and extensions to customize header row rendering.
    def add_header_row_callback(&block)
      @header_row_callbacks << block
    end

    # Extension point for subclasses and extensions to customize body row rendering.
    def add_body_row_callback(&block)
      @body_row_callbacks << block
    end

    # Extension point for subclasses and extensions to customize header row cell rendering.
    def add_header_row_cell_callback(&block)
      @header_row_cell_callbacks << block
    end

    # Extension point for subclasses and extensions to customize body row cell rendering.
    def add_body_row_cell_callback(&block)
      @body_row_cell_callbacks << block
    end

    # @internal proxy calls to row.with_cell and apply callbacks
    def with_cell(cell, &)
      if row.header?
        @header_row_cell_callbacks.each { |callback| callback.call(cell) }
        # note, block is silently dropped, it's not used for headers
        @current_row.with_cell(cell)
      else
        @body_row_cell_callbacks.each { |callback| callback.call(cell) }
        @current_row.with_cell(cell, &)
      end
    end

    def normalize_collection(collection)
      case collection
      when Array
        Tables::Collection::Array.new.apply(collection)
      when ActiveRecord::Relation
        Tables::Collection::Base.new.apply(collection)
      else
        collection
      end
    end
  end
end
