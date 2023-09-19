# frozen_string_literal: true

module Katalyst
  module Tables
    # Adds drag and drop ordering to a table.
    # See [documentation](/docs/orderable.md) for more details.
    module Orderable
      extend ActiveSupport::Concern

      FORM_CONTROLLER = "tables--orderable--form"
      ITEM_CONTROLLER = "tables--orderable--item"
      LIST_CONTROLLER = "tables--orderable--list"

      using HasHtmlAttributes

      # Enhance a given table component class with orderable support.
      # Supports extension via `included` and `extended` hooks.
      def self.make_orderable(table_class)
        # Add `orderable` columns to row components
        table_class.header_row_component.include(HeaderRow)
        table_class.body_row_component.include(BodyRow)

        # Add `orderable` slot to table component
        table_class.config_component :orderable, default: "FormComponent"
        table_class.renders_one(:orderable, lambda do |**attrs|
          orderable_component.new(table: self, **attrs)
        end)
      end

      # Support for inclusion in a table component class
      included do
        Orderable.make_orderable(self)
      end

      # Support for extending a table component instance
      def self.extended(table)
        Orderable.make_orderable(table.class)
      end

      def tbody_attributes
        return super unless orderable?

        super.merge_html(
          { data: { controller: LIST_CONTROLLER,
                    action: <<~ACTIONS.squish,
                      dragstart->#{LIST_CONTROLLER}#dragstart
                      dragenter->#{LIST_CONTROLLER}#dragenter
                      dragover->#{LIST_CONTROLLER}#dragover
                      drop->#{LIST_CONTROLLER}#drop
                    ACTIONS
                    "#{LIST_CONTROLLER}-#{FORM_CONTROLLER}-outlet" => "##{orderable.id}",
                    "#{LIST_CONTROLLER}-#{ITEM_CONTROLLER}-outlet" => "td.ordinal" } },
        )
      end

      module HeaderRow # :nodoc:
        def ordinal(attribute = :ordinal, **)
          cell(attribute, class: "ordinal", label: "")
        end
      end

      module BodyRow # :nodoc:
        def ordinal(attribute = :ordinal, id: :id)
          name  = @table.orderable.record_scope(@record, id, attribute)
          value = @record.public_send(attribute)
          cell(attribute, class: "ordinal", data: {
                 controller: ITEM_CONTROLLER,
                 "#{ITEM_CONTROLLER}-name-value" => name,
                 "#{ITEM_CONTROLLER}-value-value" => value,
               }) { t("katalyst.tables.orderable.value") }
        end

        def html_attributes
          super.merge_html(
            {
              draggable: "true",
            },
          )
        end
      end

      class FormComponent < ViewComponent::Base # :nodoc:
        attr_reader :id, :url, :scope

        def initialize(table:,
                       url:,
                       id: "#{table.id}-orderable-form",
                       scope: "order[#{table.collection.model_name.plural}]")
          super

          @table = table
          @id = id
          @url = url
          @scope = scope
        end

        def record_scope(record, id, attribute)
          "#{scope}[#{record.public_send(id)}][#{attribute}]"
        end

        def call
          form_with(id: id, url: url, method: :patch, data: { controller: FORM_CONTROLLER }) do |form|
            form.button(hidden: "")
          end
        end

        def inspect
          "#<#{self.class.name} id: #{id.inspect}, url: #{url.inspect}, scope: #{scope.inspect}>"
        end
      end
    end
  end
end
