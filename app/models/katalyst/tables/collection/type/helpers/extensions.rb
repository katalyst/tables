# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        module Helpers
          # Adds support default_value, multiple?, and filterable? to ActiveModel::Type::Value
          module Extensions
            refine(::ActiveModel::Type::Value) do
              def default_value
                nil
              end

              def multiple?
                false
              end

              def filterable?
                false
              end
            end
          end
        end
      end
    end
  end
end
