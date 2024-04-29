# frozen_string_literal: true

module Katalyst
  module Tables
    # Adds checkbox selection to a table.
    # See [documentation](/docs/selectable.md) for more details.
    module Selectable
      extend ActiveSupport::Concern

      FORM_CONTROLLER = "tables--selection--form"
      ITEM_CONTROLLER = "tables--selection--item"

      using Katalyst::HtmlAttributes::HasHtmlAttributes

      # Support for inclusion in a table component class
      # Adds an `selectable` slot and component configuration
      included do
        # Add `selectable` slot to table component
        config_component :selection, default: "Katalyst::Tables::Selectable::FormComponent"
        renders_one(:selection, lambda do |**attrs|
          selection_component.new(table: self, **attrs)
        end)
      end

      # Support for extending a table component instance
      # Adds methods to the table component instance
      def self.extended(table)
        table.extend(TableMethods)

        # ensure row components support selectable column calls
        table.send(:add_selectable_columns)
      end

      def initialize(**attributes)
        super

        # ensure row components support selectable column calls
        add_selectable_columns
      end

      private

      # Add `selectable` columns to row components
      def add_selectable_columns
        header_row_component.include(HeaderRow)
        body_row_component.include(BodyRow)
      end

      # Methods required to emulate a slot when extending an existing table.
      module TableMethods
        def with_selection(**attrs)
          @selection = FormComponent.new(table: self, **attrs)

          self
        end

        def selectable?
          @selection.present?
        end

        def selection
          @selection ||= FormComponent.new(table: self)
        end
      end

      module HeaderRow # :nodoc:
        def selection
          cell(:_selection, class: "selection", label: "")
        end
      end

      module BodyRow # :nodoc:
        def selection
          id     = @record.public_send(@table.selection.primary_key)
          params = {
            id:,
          }
          cell(:_selection,
               class: "selection",
               data:  {
                 controller:                                    ITEM_CONTROLLER,
                 "#{ITEM_CONTROLLER}-params-value"              => params.to_json,
                 "#{ITEM_CONTROLLER}-#{FORM_CONTROLLER}-outlet" => "##{@table.selection.id}",
                 action:                                        "change->#{ITEM_CONTROLLER}#change",
                 turbo_permanent:                               "",
               }) do
            tag.input(type: :checkbox)
          end
        end
      end
    end
  end
end
