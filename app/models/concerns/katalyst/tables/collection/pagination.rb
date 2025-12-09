# frozen_string_literal: true

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

          attribute :page, :integer, default: 1, filter: false
        end

        def initialize(paginate: self.class.config.paginate, **)
          super(**)

          @paginate = paginate.freeze
        end

        def paginate?
          !!@paginate
        end

        def paginate_options
          opts = @paginate.is_a?(Hash) ? @paginate : {}
          opts = opts.dup

          if PagyNavComponent.pagy_pre_8?
            opts[:anchor_string] ||= "data-turbo-action=\"replace\""
          end

          opts
        end

        class Paginate # :nodoc:
          # Pagy is not a required gem unless you're using pagination
          # Expect to see NoMethodError failures if pagy is not available
          if (pagy_method = "Pagy::Method".safe_constantize)
            include(pagy_method)
          else
            "Pagy::Backend".safe_constantize&.tap { |pagy| include(pagy) }
          end

          def initialize(app)
            @app = app
          end

          def call(collection)
            @collection = @app.call(collection)
            if collection.paginate?
              @collection.pagination, @collection.items = pagy(@collection.items, **collection.paginate_options)
            end
            @collection
          end

          # pagy shim
          def params
            @collection.to_params
          end

          # Pagy 43 expects a request object; provide the minimal hash interface it supports.
          def request
            { base_url: nil, path: nil, params:, cookie: nil }
          end
        end
      end
    end
  end
end
