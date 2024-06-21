# frozen_string_literal: true

module Katalyst
  module Tables
    module Query
      class InputComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes

        attr_reader :form

        def initialize(form:, **)
          super(**)

          @form = form
        end

        def name
          collection.class.attribute_types.detect { |_, a| a.type == :query }.first
        end

        def collection
          form.object
        end
      end
    end
  end
end
