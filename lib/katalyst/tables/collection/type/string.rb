# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      module Type
        class String < Value
          attr_reader :exact
          alias_method :exact?, :exact

          delegate :type, :serialize, :deserialize, :cast, to: :@delegate

          def initialize(exact: false, **)
            super(**)

            @exact = exact
            @delegate = ActiveModel::Type::String.new
          end

          private

          class Match
            include ActiveRecord::Sanitization::ClassMethods

            attr_reader :value

            def initialize(value)
              @value = value
            end

            def to_sql
              "%#{sanitize_sql_like(value)}%"
            end
          end

          class MatchHandler
            def call(attribute, value)
              attribute.matches(value.to_sql)
            end
          end

          def apply_filter(scope, model, attribute, value)
            if exact?
              super
            else
              model.predicate_builder.register_handler(Match, MatchHandler.new)
              scope.where(attribute.name => Match.new(value))
            end
          end
        end
      end
    end
  end
end
