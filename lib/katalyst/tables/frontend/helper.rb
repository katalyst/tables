module Katalyst::Tables
  module Frontend
    module Helper
      private

      def html_options_for_table_with(html: {}, **options)
        html_options = options.slice(:id, :class, :data).merge(html)
        html_options.stringify_keys!
      end
    end
  end
end
