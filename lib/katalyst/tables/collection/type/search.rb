# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class Search < Value
          # @overwrite Value.initialize() to require scope
          # rubocop:disable Lint/UselessMethodDefinition
          def initialize(scope:, **)
            super
          end
          # rubocop:enable Lint/UselessMethodDefinition

          def type
            :search
          end

          def filter_condition(model, _, value)
            model.public_send(scope, value)
          end
        end
      end
    end
  end
end
