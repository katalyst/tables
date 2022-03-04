# frozen_string_literal: true

require "action_view/buffers"
require "action_view/helpers/tag_helper"
require "action_view/helpers/url_helper"

module Test
  class Template
    include Katalyst::Tables::Frontend
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper

    attr_accessor :output_buffer

    def translate(_key, default:)
      default
    end
  end

  class Record
    def initialize(key:)
      @key = key
    end

    attr_accessor :key
  end
end
