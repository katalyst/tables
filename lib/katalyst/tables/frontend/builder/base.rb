# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/module/delegation"

require_relative "../helper"

module Katalyst
  module Tables
    module Frontend
      module Builder
        class Base # :nodoc:
          include Helper

          attr_reader :table

          delegate :sort,
                   :table_header_cell,
                   :table_header_row,
                   :table_body_cell,
                   :table_body_row,
                   :template,
                   to: :table

          delegate :content_tag,
                   :link_to,
                   :render,
                   :request,
                   :translate,
                   :with_output_buffer,
                   to: :template

          def initialize(table, **options)
            @table  = table
            @header = false
            self.options(**options)
          end

          def header?
            @header
          end

          def body?
            !@header
          end

          private

          def table_tag(type, value = nil, &block)
            # capture output before calling tag, to allow users to modify `options` during body execution
            value = with_output_buffer(&block) if block_given?

            content_tag(type, value, @html_options, &block)
          end
        end
      end
    end
  end
end
