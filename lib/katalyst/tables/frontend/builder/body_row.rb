# frozen_string_literal: true

require_relative "base"

module Katalyst
  module Tables
    module Frontend
      module Builder
        class BodyRow < Base # :nodoc:
          attr_reader :object

          def initialize(table, object)
            super table

            @object = object
          end

          def build
            table_tag(:tr) { yield self, object }
          end

          def cell(method, **options, &block)
            table_body_cell(object, method, **options, &block)
          end
        end
      end
    end
  end
end
