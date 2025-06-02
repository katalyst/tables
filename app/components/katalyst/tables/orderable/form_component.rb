# frozen_string_literal: true

module Katalyst
  module Tables
    module Orderable
      class FormComponent < ViewComponent::Base # :nodoc:
        include Katalyst::Tables::Identifiable::Defaults

        attr_reader :id, :url

        # @param collection [Katalyst::Tables::Collection::Core] the collection to render
        # @param url [String] the url to submit the form to (e.g. <resources>_order_path)
        # @param id [String] the id of the form element (defaults to <resources>_order_form)
        # @param scope [String] the base scope to use for form inputs (defaults to order[<resources>])
        def initialize(collection:, url:, id: nil, scope: nil)
          super()

          @id    = id || Orderable.default_form_id(collection)
          @url   = url
          @scope = scope || Orderable.default_scope(collection)
        end

        def call
          form_with(id:, url:, method: :patch, data: {
                      controller:                       FORM_CONTROLLER,
                      "#{FORM_CONTROLLER}-scope-value": @scope,
                    }) do |form|
            form.button(hidden: "")
          end
        end

        def inspect
          "#<#{self.class.name} id: #{id.inspect}, url: #{url.inspect}>"
        end
      end
    end
  end
end
