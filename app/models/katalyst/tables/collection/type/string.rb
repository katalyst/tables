# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class String < Value
          include ActiveRecord::Sanitization::ClassMethods

          attr_reader :exact

          delegate :type, :serialize, :deserialize, :cast, to: :@delegate

          def initialize(exact: false, **)
            super(**)

            @exact = exact
            @delegate = ActiveModel::Type::String.new
          end

          private

          def filter_condition(model, column, value)
            if exact || scope
              super
            else
              model.where(model.arel_table[column].matches("%#{sanitize_sql_like(value)}%"))
            end
          end
        end
      end
    end
  end
end
