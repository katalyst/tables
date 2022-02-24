require_relative "frontend/helper"
require_relative "frontend/builder"

module Katalyst::Tables
  module Frontend
    include Helper

    def table_with(collection:, **options, &block)
      table_options = options.slice(:header, :sort)

      table_options[:object_name] ||= collection.try(:model_name)&.param_key

      html_options = html_options_for_table_with(**options)

      Builder.new(self, collection, table_options, html_options).build(&block)
    end
  end
end
