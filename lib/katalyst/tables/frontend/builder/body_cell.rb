# frozen_string_literal: true

require_relative "base"

module Katalyst
  module Tables
    module Frontend
      module Builder
        class BodyCell < Base # :nodoc:
          attr_reader :object, :method

          def initialize(table, object, method, **options)
            super table, **options

            @type   = options.fetch(:heading, false) ? :th : :td
            @object = object
            @method = method
          end

          def build
            table_tag(@type) { block_given? ? yield(self).to_s : value.to_s }
          end

          def value
            object.public_send(method)
          end
        end
      end
    end
  end
end
