# frozen_string_literal: true

module Katalyst
  module Tables
    module Selectable
      class FormComponent < ViewComponent::Base # :nodoc:
        attr_reader :id, :primary_key

        def initialize(table:,
                       id: nil,
                       primary_key: :id)
          super

          @table       = table
          @id          = id
          @primary_key = primary_key

          if @id.nil?
            table_id = table.try(:id)

            raise ArgumentError, "Table selection requires an id" if table_id.nil?

            @id = "#{table_id}_selection"
          end
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
      end
    end
  end
end
