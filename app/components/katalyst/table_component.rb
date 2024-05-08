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
      with_cell(Tables::CellComponent.new(
                  collection:, row:, column:, record:, label:, heading:, **,
                ), &)
    end

    alias_method :text, :cell

    # Generates a column from boolean values rendered as "Yes" or "No".
    #
    # @param column [Symbol] the column's name, called as a method on the record
    # @param label [String|nil] the label to use for the column header
    # @param heading [boolean] if true, data cells will use `th` tags
    # @param ** [Hash] HTML attributes to be added to column cells
    # @param & [Proc] optional block to alter the cell content
    # @return [void]
    #
    # @example Render a boolean column indicating whether the record is active
    #   <% row.boolean :active %> # => <td>Yes</td>
    def boolean(column, label: nil, heading: false, **, &)
      with_cell(Tables::Cells::BooleanComponent.new(
                  collection:, row:, column:, record:, label:, heading:, **,
                ), &)
    end

    # Generates a column from date values rendered using I18n.l.
    # The default format is :default, but it can be overridden.
    #
    # @param column [Symbol] the column's name, called as a method on the record
    # @param label [String|nil] the label to use for the column header
    # @param heading [boolean] if true, data cells will use `th` tags
    # @param format [Symbol] the I18n date format to use when rendering
    # @param relative [Boolean] if true, the date may be shown as a relative date (if within 5 days)
    # @param ** [Hash] HTML attributes to be added to column cells
    # @param & [Proc] optional block to alter the cell content
    # @return [void]
    #
    # @example Render a date column describing when the record was created
    #   <% row.date :created_at %> # => <td>29 Feb 2024</td>
    def date(column, label: nil, heading: false, format: :default, relative: true, **, &)
      with_cell(Tables::Cells::DateComponent.new(
                  collection:, row:, column:, record:, label:, heading:, format:, relative:, **,
                ), &)
    end

    # Generates a column from datetime values rendered using I18n.l.
    # The default format is :default, but it can be overridden.
    #
    # @param column [Symbol] the column's name, called as a method on the record
    # @param label [String|nil] the label to use for the column header
    # @param heading [boolean] if true, data cells will use `th` tags
    # @param format [Symbol] the I18n datetime format to use when rendering
    # @param relative [Boolean] if true, the datetime may be(if today) shown as a relative date/time
    # @param ** [Hash] HTML attributes to be added to column cells
    # @param & [Proc] optional block to alter the cell content
    # @return [void]
    #
    # @example Render a datetime column describing when the record was created
    #   <% row.datetime :created_at %> # => <td>29 Feb 2024, 5:00pm</td>
    def datetime(column, label: nil, heading: false, format: :default, relative: true, **, &)
      with_cell(Tables::Cells::DateTimeComponent.new(
                  collection:, row:, column:, record:, label:, heading:, format:, relative:, **,
                ), &)
    end

    # Generates a column from numeric values formatted appropriately.
    #
    # @param column [Symbol] the column's name, called as a method on the record
    # @param label [String|nil] the label to use for the column header
    # @param heading [boolean] if true, data cells will use `th` tags
    # @param ** [Hash] HTML attributes to be added to column cells
    # @param & [Proc] optional block to alter the cell content
    # @return [void]
    #
    # @example Render the number of comments on a post
    #   <% row.number :comment_count %> # => <td>0</td>
    def number(column, label: nil, heading: false, **, &)
      with_cell(Tables::Cells::NumberComponent.new(
                  collection:, row:, column:, record:, label:, heading:, **,
                ), &)
    end

    # Generates a column from numeric values rendered using `number_to_currency`.
    #
    # @param column [Symbol] the column's name, called as a method on the record
    # @param label [String|nil] the label to use for the column header
    # @param heading [boolean] if true, data cells will use `th` tags
    # @param options [Hash] options to be passed to `number_to_currency`
    # @param ** [Hash] HTML attributes to be added to column cells
    # @param & [Proc] optional block to alter the cell content
    # @return [void]
    #
    # @example Render a currency column for the price of a product
    #   <% row.currency :price %> # => <td>$3.50</td>
    def currency(column, label: nil, heading: false, options: {}, **, &)
      with_cell(Tables::Cells::CurrencyComponent.new(
                  collection:, row:, column:, record:, label:, heading:, options:, **,
                ), &)
    end

    # Generates a column containing HTML markup.
    #
    # @param column [Symbol] the column's name, called as a method on the record
    # @param label [String|nil] the label to use for the column header
    # @param heading [boolean] if true, data cells will use `th` tags
    # @param ** [Hash] HTML attributes to be added to column cells
    # @param & [Proc] optional block to alter the cell content
    # @return [void]
    #
    # @note This method assumes that the method returns HTML-safe content.
    #   If the content is not HTML-safe, it will be escaped.
    #
    # @example Render a description column containing HTML markup
    #   <% row.rich_text :description %> # => <td><em>Emphasis</em></td>
    def rich_text(column, label: nil, heading: false, options: {}, **, &)
      with_cell(Tables::Cells::RichTextComponent.new(
                  collection:, row:, column:, record:, label:, heading:, options:, **,
                ), &)
    end

    # Generates a column that links to the record's show page (by default).
    #
    # @param column [Symbol] the column's name, called as a method on the record
    # @param label [String|nil] the label to use for the column header
    # @param heading [boolean] if true, data cells will use `th` tags
    # @param url [Symbol|String|Proc] arguments for url_For, defaults to the record
    # @param link [Hash] options to be passed to the link_to helper
    # @param ** [Hash] HTML attributes to be added to column cells
    # @param & [Proc] optional block to alter the cell content
    # @return [void]
    #
    # @example Render a column containing the record's title, linked to its show page
    #   <% row.link :title %> # => <td><a href="/admin/post/15">About us</a></td>
    # @example Render a column containing the record's title, linked to its edit page
    #   <% row.link :title, url: :edit_admin_post_path do |cell| %>
    #      Edit <%= cell %>
    #   <% end %>
    #   # => <td><a href="/admin/post/15/edit">Edit About us</a></td>
    # TODO: move to Koi, this doesn't seem generally applicable (example is specific to Koi)
    def link(column, label: nil, heading: false, url: record, link: {}, **, &)
      with_cell(Tables::Cells::LinkComponent.new(
                  collection:, row:, column:, record:, label:, heading:, url:, link:, **,
                ), &)
    end

    # Generates a column that renders an ActiveStorage attachment as a downloadable link.
    #
    # @param column [Symbol] the column's name, called as a method on the record
    # @param label [String|nil] the label to use for the column header
    # @param heading [boolean] if true, data cells will use `th` tags
    # @param variant [Symbol] the variant to use when rendering the image (default :thumb)
    # @param ** [Hash] HTML attributes to be added to column cells
    # @param & [Proc] optional block to alter the cell content
    # @return [void]
    #
    # @example Render a column containing a download link to the record's background image
    #   <% row.attachment :background %> # => <td><a href="...">background.png</a></td>
    # TODO: move to Koi, not generally applicable
    def attachment(column, label: nil, heading: false, variant: :thumb, **, &)
      with_cell(Tables::Cells::AttachmentComponent.new(
                  collection:, row:, column:, record:, label:, heading:, variant:, **,
                ), &)
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
