# frozen_string_literal: true

module Katalyst
  module Tables
    module Selectable
      class FormComponent < ViewComponent::Base # :nodoc:
        include Katalyst::Tables::Identifiable::Defaults

        attr_reader :id, :primary_key

        # @param collection [Katalyst::Tables::Collection::Core] the collection to render
        # @param id [String] the id of the form element (defaults to <resources>_selection_form)
        # @param primary_key [String] the primary key of the record in the collection (defaults to :id)
        def initialize(collection:,
                       id: nil,
                       primary_key: :id)
          super

          @collection  = collection
          @id          = id || Selectable.default_form_id(collection)
          @primary_key = primary_key
        end

        def inspect
          "#<#{self.class.name} id: #{id.inspect}, primary_key: #{primary_key.inspect}>"
        end

        private

        def form_controller
          FORM_CONTROLLER
        end

        def form_target(value)
          "#{FORM_CONTROLLER}-target=#{value}"
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
