# frozen_string_literal: true

require "pagy/backend"

module Katalyst
  module Tables
    module Collection
      # Adds pagination support for a collection.
      #
      # Pagination will be applied if the collection is configured to paginate
      # by either specifying `config.paginate = true` or passing
      # `paginate: true` to the initializer.
      #
      # If the value given to `paginate` is a hash, it will be passed to the
      # `pagy` gem as options.
      #
      # If `page` is present in params it will be passed to pagy.
      module Pagination
        extend ActiveSupport::Concern

        included do
          attr_accessor :pagination

          attribute :page, :integer, default: 1

          config_accessor :paginate
        end

        def initialize(paginate: config.paginate, **options)
          super(**options)

          @paginate = paginate
        end

        def paginate?
          !!@paginate
        end

        def paginate_options
          @paginate.is_a?(Hash) ? @paginate : {}
        end

        class Paginate # :nodoc:
          include Pagy::Backend

          def initialize(app)
            @app = app
          end

          def call(collection)
            @collection = @app.call(collection)
            if collection.paginate?
              @collection.pagination, @collection.items = pagy(@collection.items, collection.paginate_options)
            end
            @collection
          end

          # pagy shim
          def params
            @collection.attributes.with_indifferent_access
          end
        end
      end
    end
  end
end
