# frozen_string_literal: true

module Katalyst
  module Tables
    module Selectable
      class FormComponent < ViewComponent::Base # :nodoc:
        include Katalyst::HtmlAttributes

        using Katalyst::HtmlAttributes::HasHtmlAttributes
        include Katalyst::Tables::Identifiable::Defaults

        attr_reader :id, :primary_key

        # @param collection [Katalyst::Tables::Collection::Core] the collection to render
        # @param id [String] the id of the form element (defaults to <resources>_selection_form)
        # @param primary_key [String] the primary key of the record in the collection (defaults to :id)
        def initialize(collection:,
                       id: nil,
                       primary_key: :id)
          super()

          @collection  = collection
          @id          = id || Selectable.default_form_id(collection)
          @primary_key = primary_key
        end

        def inspect
          "#<#{self.class.name} id: #{id.inspect}, primary_key: #{primary_key.inspect}>"
        end

        # Renders the number of selected rows and the model name, e.g. "1 person" or "2 people", updated as the
        # selection changes.
        #
        # The result is HTML safe, so it can be interpolated into an `_html` translation to describe the
        # selection, e.g. `t(".download_html", selection: selection.selection_tag)`.
        #
        # @param options [Hash] html attributes for the wrapping span (id, aria, class, data, html)
        def selection_tag(**options)
          tag.span(safe_join([count_tag, " ", singular_tag, plural_tag]), **options_to_html_attributes(options))
        end

        # Renders a span containing the number of selected rows, updated as the selection changes.
        #
        # @param options [Hash] html attributes for the span (id, aria, class, data, html)
        def count_tag(**options)
          target_tag("count", "0", options)
        end

        # Renders a span containing the singular model name, visible when exactly one row is selected.
        #
        # @param options [Hash] html attributes for the span (id, aria, class, data, html)
        def singular_tag(**options)
          target_tag("singular", singular_name, options, hidden: true)
        end

        # Renders a span containing the plural model name, visible unless exactly one row is selected.
        #
        # @param options [Hash] html attributes for the span (id, aria, class, data, html)
        def plural_tag(**options)
          target_tag("plural", plural_name, options)
        end

        private

        def default_html_attributes
          {
            id:,
            class: "tables--selection--form",
            data:  {
              controller:   form_controller,
              turbo_action: "replace",
            },
            html:  { action: false, hidden: "" },
          }
        end

        def form_controller
          FORM_CONTROLLER
        end

        def target_tag(target, content, options, **defaults)
          attributes = { data: { "#{FORM_CONTROLLER}-target": target }, **defaults }
          tag.span(content, **attributes.merge_html(options_to_html_attributes(options)))
        end

        def singular_name
          @collection.model_name.human(count: 1, default: @collection.model_name.human).downcase
        end

        def plural_name
          @collection.model_name.human(count: 2, default: @collection.model_name.human.pluralize).downcase
        end
      end
    end
  end
end
