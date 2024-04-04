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

      using Katalyst::HtmlAttributes::HasHtmlAttributes

      # Support for inclusion in a table component class
      # Adds an `orderable` slot and component configuration
      included do
        # Add `orderable` slot to table component
        config_component :orderable, default: "Katalyst::Tables::Orderable::FormComponent"
        renders_one(:orderable, lambda do |**attrs|
          orderable_component.new(table: self, **attrs)
        end)
      end

      # Support for extending a table component instance
      # Adds methods to the table component instance
      def self.extended(table)
        table.extend(TableMethods)

        # ensure row components support orderable column calls
        table.send(:add_orderable_columns)
      end

      def initialize(**attributes)
        super

        # ensure row components support orderable column calls
        add_orderable_columns
      end

      def tbody_attributes
        return super unless orderable?

        super.merge_html(
          { data: { controller: LIST_CONTROLLER,
                    action: <<~ACTIONS.squish,
                      mousedown->#{LIST_CONTROLLER}#mousedown
                    ACTIONS
                    "#{LIST_CONTROLLER}-#{FORM_CONTROLLER}-outlet" => "##{orderable.id}",
                    "#{LIST_CONTROLLER}-#{ITEM_CONTROLLER}-outlet" => "td.ordinal" } },
        )
      end

      private

      # Add `orderable` columns to row components
      def add_orderable_columns
        header_row_component.include(HeaderRow)
        body_row_component.include(BodyRow)
      end

      # Methods required to emulate a slot when extending an existing table.
      module TableMethods
        def with_orderable(**attrs)
          @orderable = FormComponent.new(table: self, **attrs)

          self
        end

        def orderable?
          @orderable.present?
        end

        def orderable
          @orderable
        end
      end

      module HeaderRow # :nodoc:
        def ordinal(attribute = :ordinal, **)
          cell(attribute, class: "ordinal", label: "")
        end
      end

      module BodyRow # :nodoc:
        def ordinal(attribute = :ordinal, primary_key: :id)
          id = @record.public_send(primary_key)
          params = {
            id_name:     @table.orderable.record_scope(id, primary_key),
            id_value:    id,
            index_name:  @table.orderable.record_scope(id, attribute),
            index_value: @record.public_send(attribute),
          }
          cell(attribute, class: "ordinal", draggable: true, data: {
                 controller:                        ITEM_CONTROLLER,
                 "#{ITEM_CONTROLLER}-params-value": params.to_json,
               }) { t("katalyst.tables.orderable.value") }
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

        def record_scope(id, attribute)
          "#{scope}[#{id}][#{attribute}]"
        end

        def call
          form_with(id:, url:, method: :patch, data: { controller: FORM_CONTROLLER }) do |form|
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
