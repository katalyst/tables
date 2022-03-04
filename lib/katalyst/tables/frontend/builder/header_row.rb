# frozen_string_literal: true

require_relative "body_row"

module Katalyst
  module Tables
    module Frontend
      module Builder
        class HeaderRow < BodyRow # :nodoc:
          def initialize(table)
            super table, nil

            @header = true
          end

          def cell(method, **options, &block)
            table_header_cell(method, **options, &block)
          end
        end
      end
    end
  end
end
