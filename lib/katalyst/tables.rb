# frozen_string_literal: true

require "view_component"
require "katalyst/html_attributes"

require_relative "tables/config"
require_relative "tables/engine"

module Katalyst
  module Tables
    class Error < StandardError; end

    def self.config
      @config ||= Config.new
    end

    def self.configure
      yield config
    end
  end
end
