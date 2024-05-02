# frozen_string_literal: true

using Katalyst::HtmlAttributes::HasHtmlAttributes

module Katalyst
  module Tables
    module Body
      # Displays a link to the record
      # The link text is the value of the attribute
      # @see Koi::Tables::BodyRowComponent#link
      class LinkComponent < BodyCellComponent
        def initialize(table, record, attribute, url:, link: {}, **options)
          super(table, record, attribute, **options)

          @url = url
          @link_options = link
        end

        def call
          content # ensure content is set before rendering options

          link = content.present? && url.present? ? link_to(content, url, @link_options) : content.to_s
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
