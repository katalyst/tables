# frozen_string_literal: true

module Katalyst
  module Tables
    module Collection
      # Adds stackable reducers to a collection.
      # Inspired by ActiveDispatch::MiddlewareStack which unfortunately can't
      # be used due to monkey patches from gems such as NewRelic which assume
      # it is only used for Rack middleware.
      module Reducers
        extend ActiveSupport::Concern

        included do
          class_attribute :reducers, default: Stack.new
        end

        class_methods do
          delegate :use, :insert, to: :reducers
        end

        class Stack # :nodoc:
          def initialize
            @stack = []
          end

          def use(klass)
            @stack << Reducer.new(klass) unless index(klass)
          end

          def insert(other, klass)
            @stack.insert(index(other), Reducer.new(klass))
          end

          def index(klass)
            @stack.index(Reducer.new(klass))
          end

          def build(&block)
            @stack.freeze.reduce(block) do |app, reducer|
              reducer.build(app)
            end
          end
        end

        class Reducer # :nodoc:
          attr_reader :klass

          def initialize(klass)
            @klass = klass
          end

          def build(app)
            klass.new(app)
          end

          def ==(other)
            klass.name == other.klass.name
          end

          def inspect
            "#<#{self.class.name} #{klass.name}>"
          end
        end
      end
    end
  end
end
