# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        module Helpers
          # Adds support for multiple: true
          module Multiple
            def initialize(multiple: false, **)
              super(**)

              @multiple = multiple
            end

            def multiple?
              @multiple
            end

            using Extensions

            def default_value
              multiple? ? [] : super
            end
          end
        end
      end
    end
  end
end
