# frozen_string_literal: true

module Katalyst
  module Tables
    module Body
      # Displays a link to the record
      # The link text is the value of the attribute
      # @see Koi::Tables::BodyRowComponent#link
      class LinkComponent < BodyCellComponent
        define_html_attribute_methods :link_attributes

        def initialize(table, record, attribute, url:, link: {}, **options)
          super(table, record, attribute, **options)

          @url = url

          self.link_attributes = link
        end

        def call
          content # ensure content is set before rendering options

          link = content.present? && url.present? ? link_to(content, url, **link_attributes) : content.to_s
          content_tag(@type, link, **html_attributes)
        end

        def url
          case @url
          when Symbol
            # helpers are not available until the component is rendered
            @url = helpers.public_send(@url, record)
          when Proc
            @url = @url.call(record)
          else
            @url
          end
        end
      end
    end
  end
end
